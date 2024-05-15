let rec map_fs root f acc =
  let files = Sys.readdir root in
  Sys.chdir root;
  Array.fold_left
    (fun acc fname ->
      if Sys.is_directory fname then (
        map_fs fname f acc)
      else f fname acc)
    acc files

let stat_size_test root =
  if not (Sys.is_directory root) then failwith "Not a valid directory";
  map_fs root
    (fun fname acc ->
      let s = Unix.stat fname in
      acc + s.st_size)
    0

let () =
  let root = try Sys.argv.(1) with _ -> "root" in
  let size = stat_size_test root / 1_000_000 in
  Format.printf "Total size = %d MB" size
