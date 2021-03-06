open Core

let exit_with_message exit_code message =
  print_endline message;
  exit exit_code

let preprocess s =
  let pattern = Str.regexp "\\(,\\|\\ \\|(\\|)\\)" in
  let remove pattern = Str.global_replace pattern "" in
  s |> remove pattern

(* expect quoted string separated by space like '255 255 255' *)
let parse_one_arg arg =
  try
    Some (String.split arg ~on:(' ') |> List.map ~f:(fun e -> preprocess e))
  with _ -> None

let int_list_of_string_list l =
  try
    List.map l ~f:(fun e -> int_of_string (preprocess e))
  with _ -> exit_with_message 3 "Argument is not number"

let to_hex rgb_code =
  sprintf "%02X" rgb_code

let validate_args args =
  List.iter args ~f:(fun arg ->
      if arg < 0 || arg > 255 then exit_with_message 2 "Value is out of range (0 <= n <= 255)"
    )

let main raw_args =
  let raw_args_ = raw_args |> Array.to_list |> List.tl_exn in
  let arglen = List.length raw_args_ in
  let args = match arglen with
    | 1 -> (
        match parse_one_arg @@ List.nth_exn raw_args_ 0 with
        | Some l_ -> int_list_of_string_list l_
        | _ -> exit_with_message 1 @@ sprintf "rgb-to-hex takes 3 args (%d args given)" arglen
      )
    | 3 -> int_list_of_string_list raw_args_
    | _ -> exit_with_message 1 @@ sprintf "rgb-to-hex takes 3 args (%d args given)" arglen
  in

  validate_args args;

  let result = Buffer.create 7 in
  Buffer.add_char result '#';
  List.iter args ~f:(fun e -> Buffer.add_string result @@ to_hex e);
  Buffer.contents result, Hashtbl.find Colors.color_names (Buffer.contents result)

let () =
  let (color_code, color_name) = main @@ Sys.get_argv () in
  print_endline color_code;
  match color_name with
  | Some x -> print_endline x
  | None -> ()

