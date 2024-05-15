[@@@warning "-32"]
type filesystem =
  | File of string * int (* File (name, size) *)
  | Directory of string * int * filesystem list (* Directory(name, contents) *)
[@@deriving show { with_path = false }]

let rec gen ~max_depth ~max_breadth ~max_file_sz () : filesystem list * int =
  let num_obj = Random.int max_breadth in
  (* Empty directory if no objects *)
  if num_obj = 0 then ([], 0) (* Empty directory if max depth hit *)
  else if max_depth <= 0 then ([], 0)
  else
    let num_dirs = Random.int num_obj in
    let rec aux cnt acc sz =
      if cnt >= num_obj then (acc, sz)
      else if cnt < num_dirs then
        let dir, dir_sz =
          gen ~max_depth:(max_depth - 1) ~max_breadth ~max_file_sz ()
        in
        (* The size of a directory file is standard 4096 *)
        let entry = Directory ("dir_" ^ string_of_int cnt, 4096, dir) in
        (* We pass the size of the contents of the directory up to the root *)
        aux (cnt + 1) (entry :: acc) (sz + dir_sz)
      else
        let file_sz = (Random.int max_file_sz) + 1 in
        let entry = File ("file_" ^ string_of_int cnt, file_sz) in
        aux (cnt + 1) (entry :: acc) (sz + file_sz)
    in
    aux 0 [] 0

let rec gen_to_actual_fs (fs : filesystem) =
  match fs with
  | File (name, sz) ->
      let sz' = "-l" ^ string_of_int sz in
      let cmd = Filename.quote_command "fallocate" [ sz'; name ] in
      let ret = Sys.command cmd in
      if ret <> 0 then exit ret
  | Directory (name, _, contents) ->
      Sys.mkdir name 0o711;
      Sys.chdir name;
      List.iter (fun ent -> gen_to_actual_fs ent) contents;
      Sys.chdir ".."

let to_disk ?(base_dir = "tmp_fs") (fs : filesystem) =
  if Sys.file_exists base_dir then
    failwith "Base directory exists, prevent cloberring";
  gen_to_actual_fs fs

let () =
  let max_depth = try Sys.argv.(1) |> int_of_string with _ -> 10 in
  let max_breadth = try Sys.argv.(2) |> int_of_string with _ -> 100 in
  let max_file_sz = try Sys.argv.(3) |> int_of_string with _ -> 1_000_000 in
  Random.self_init ();
  let root, sz = gen ~max_depth ~max_breadth ~max_file_sz () in
  let mb_sz = sz / 1_000_000 in
  let fs = Directory ("root", 4096, root) in
  (* Format.printf "@[<v>Filesystem structure to be generated:@,@]@."; *)
  (* pp_filesystem Format.std_formatter fs; *)
  Format.printf
    "\n\n\
     This will require %d MB of space Are you sure you want to generate this? \
     (y or n) "
    mb_sz;
  match read_line () with
  | "n" -> exit 0
  | "y" -> to_disk fs
  | _ -> failwith "Input not recognized"
