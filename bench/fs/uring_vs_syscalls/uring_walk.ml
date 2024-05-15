let uring = Uring.create ~queue_depth:4096 ()

let rec dir_walk root f =
  let objs = Sys.readdir root in
  Sys.chdir root;
  Array.iter
    (fun obj ->
      if Sys.is_directory obj then dir_walk obj f
      else
        ignore (f obj))
    objs

let process fname =
  let open Uring in
  let stat = Uring.Statx.create () in
  let _job = statx uring ~mask:Statx.Mask.size fname stat Statx.Flags.empty () in
  wait uring |> function
  | None -> failwith "None"
  | Some { result=_; data=_ } ->
    Printf.printf "%s size: %Ld\n" fname (Statx.size stat)

let () =
  let path = try Sys.argv.(1) with _ -> "root" in
  dir_walk path process;
