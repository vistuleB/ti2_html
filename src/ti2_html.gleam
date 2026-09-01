import argv
import desugaring as vr
import desugaring/core as infra
import desugaring/writerly_defaults as wd
import gleam/dict
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/string
import html_to_writerly
import local_desugarers
import on
import pipeline
import vxml.{type VXML, Attr}
import vxml/blame.{type Blame} as bl
import vxml/io_lines.{type OutputLine, OutputLine}

const ins = string.inspect

type FragmentType {
  Chapter(Int)
  TOCAuthorSuppliedContent
}

type Ti2SplitterError {
  NoTOCAuthorSuppliedContent
  MoreThanOneTOCAuthorSuppliedContent
}

type Ti2EmitterError {
  NumberAttributeAlreadyExists(FragmentType, Int)
}

fn blame_us(message: String) -> Blame {
  bl.Ext([], message)
}

fn prepend_0(number: String) {
  case string.length(number) {
    1 -> "0" <> number
    _ -> number
  }
}

fn our_splitter(
  root: VXML,
) -> Result(
  #(List(vr.OutputFragment(FragmentType, VXML)), vr.Feedback),
  Ti2SplitterError,
) {
  let chapter_vxmls = infra.descendants_with_tag(root, "section")
  // io.println(
  //   "the number of chapters found was: "
  //   <> chapter_vxmls |> list.length |> string.inspect,
  // )
  use toc_vxml <- on.error_ok(
    infra.v_unique_child_with_singleton_error(root, "TOCAuthorSuppliedContent"),
    fn(error) {
      case error {
        infra.MoreThanOne -> Error(MoreThanOneTOCAuthorSuppliedContent)
        infra.LessThanOne -> Error(NoTOCAuthorSuppliedContent)
      }
    },
  )

  Ok(#(
    list.flatten([
      [
        vr.OutputFragment(
          TOCAuthorSuppliedContent,
          "vorlesungsskript.html",
          toc_vxml,
        ),
      ],
      list.index_map(chapter_vxmls, fn(vxml, index) {
        let assert Some(title_attr) =
          infra.v_first_attr_with_key(vxml, "title_en")
        let assert Some(number_attribute) =
          infra.v_first_attr_with_key(vxml, "number")
        let section_name =
          number_attribute.val
          |> string.split(".")
          |> list.map(prepend_0)
          |> string.join("-")
          <> "-"
          <> title_attr.val |> string.replace(" ", "-")
        vr.OutputFragment(
          Chapter(index + 1),
          "lecture-notes/" <> section_name <> ".html",
          vxml,
        )
      }),
    ]),
    vr.NoFeedback,
  ))
}

fn ti2_section_emitter(
  path: String,
  fragment: VXML,
  fragment_type: FragmentType,
  number: Int,
) -> Result(vr.OutputFragment(FragmentType, List(OutputLine)), Ti2EmitterError) {
  let number_attribute =
    Attr(blame_us("lbp_fragment_emitterL65"), "count", ins(number))

  use fragment <- on.error_ok(
    infra.v_prepend_unique_key_attr(fragment, number_attribute),
    on_error: fn(_) {
      Error(NumberAttributeAlreadyExists(fragment_type, number))
    },
  )

  let lines =
    list.flatten([
      [
        OutputLine(
          blame_us("ti2_fragment_emitter"),
          0,
          "<!DOCTYPE html>\n<html>\n<head>",
        ),
        OutputLine(
          blame_us("ti2_fragment_emitter"),
          2,
          "    <link rel=\"icon\" href=\"data:,\">
    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">
    <title></title>
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
    <link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css\">
    <link rel=\"stylesheet\" type=\"text/css\" href=\"../lecture-notes.css\" />
    <link rel=\"stylesheet\" type=\"text/css\" href=\"../TI.css\" />
    <link rel=\"stylesheet\" type=\"text/css\" href=\"../tooltip-3003.css\" />
    <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js\"></script>
    <script type=\"text/javascript\" src=\"../numbered-title.js\"></script>
    <script type=\"text/javascript\" src=\"../mathjax_setup.js\"></script>
    <script type=\"text/javascript\" src=\"../carousel.js\"></script>
    <script type=\"text/javascript\" src=\"../sendCmdTo3003.js\"></script>
    <script type=\"text/javascript\" id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js\"></script>",
        ),
        OutputLine(blame_us("ti2_fragment_emitter"), 0, "</head>\n<body>"),
      ],
      vxml.vxml_to_html_output_lines(fragment, 0, 2),
      [
        OutputLine(blame_us("ti2_fragment_emitter"), 0, "</body>"),
        OutputLine(blame_us("ti2_fragment_emitter"), 0, ""),
      ],
    ])

  Ok(vr.OutputFragment(fragment_type, path, lines))
}

fn toc_emitter(
  path: String,
  fragment: VXML,
  fragment_type: FragmentType,
) -> Result(vr.OutputFragment(FragmentType, List(OutputLine)), Ti2EmitterError) {
  let lines =
    list.flatten([
      [
        OutputLine(blame_us("toc_emitter"), 0, "<!DOCTYPE html>"),
        OutputLine(blame_us("toc_emitter"), 0, "<html>"),
        OutputLine(blame_us("toc_emitter"), 0, "<head>"),
        OutputLine(
          blame_us("toc_emitter"),
          2,
          "<link rel=\"icon\" type=\"image/x-icon\" href=\"logo.png\">",
        ),
        OutputLine(blame_us("toc_emitter"), 2, "<meta charset=\"utf-8\">"),
        OutputLine(
          blame_us("toc_emitter"),
          2,
          "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          2,
          "<link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css\">",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          2,
          "<link rel=\"stylesheet\" href=\"lecture-notes.css\">",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          2,
          "<link rel=\"stylesheet\" type=\"text/css\" href=\"TI.css\" />",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          2,
          "<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js\"></script>",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          2,
          "<script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js\"></script>",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          2,
          "<script type=\"text/javascript\" src=\"./mathjax_setup.js\"></script>",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          2,
          "<script type=\"text/javascript\" id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js\"></script>",
        ),
        OutputLine(blame_us("toc_emitter"), 0, "</head>"),
        OutputLine(blame_us("toc_emitter"), 0, "<body>"),
        OutputLine(blame_us("toc_emitter"), 0, "  <div>"),
        OutputLine(
          blame_us("toc_emitter"),
          0,
          "    <p><a href=\"index.html\">zur Kursübersicht</a></p>",
        ),
        OutputLine(blame_us("toc_emitter"), 0, "  </div>"),
        OutputLine(
          blame_us("toc_emitter"),
          0,
          "  <div class=\"container\" style=\"text-align:center;\">",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          0,
          "    <div style=\"text-align:center;margin-bottom:4em;\">",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          0,
          "      <h1><span class=\"coursename\">Theoretische Informatik 2</span> - Vorlesungsskript</h1>",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          0,
          "      <h3>Bachelor-Studium Informatik</h3>",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          0,
          "      <h3>Dominik Scheder, TU Chemnitz</h3>",
        ),
        OutputLine(blame_us("toc_emitter"), 0, "    </div>"),
        OutputLine(
          blame_us("toc_emitter"),
          0,
          "    <div class=\"row content\">",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          0,
          "      <div class=\"col-sm-9 text-left\">",
        ),
        OutputLine(
          blame_us("toc_emitter"),
          0,
          "        <div id=\"table-of-content-div\">",
        ),
      ],
      fragment
        |> infra.v_get_children
        |> list.map(vxml.vxml_to_html_output_lines(_, 8, 2))
        |> list.flatten,
      [
        OutputLine(blame_us("toc_emitter"), 0, "        </div>"),
        OutputLine(blame_us("toc_emitter"), 0, "      </div>"),
        OutputLine(blame_us("toc_emitter"), 0, "    </div>"),
        OutputLine(blame_us("toc_emitter"), 0, "  </div>"),
        OutputLine(blame_us("toc_emitter"), 0, "</body>"),
        OutputLine(blame_us("toc_emitter"), 0, ""),
      ],
    ])

  Ok(vr.OutputFragment(fragment_type, path, lines))
}

fn ti2_emitter(
  pair: vr.OutputFragment(FragmentType, VXML),
) -> Result(
  #(vr.OutputFragment(FragmentType, List(OutputLine)), vr.Feedback),
  Ti2EmitterError,
) {
  let vr.OutputFragment(fragment_type, path, vxml) = pair
  use fragment <- on.ok(case fragment_type {
    Chapter(n) -> ti2_section_emitter(path, vxml, fragment_type, n)
    TOCAuthorSuppliedContent -> toc_emitter(path, vxml, fragment_type)
  })
  Ok(#(fragment, vr.NoFeedback))
}

fn cli_usage_supplementary() -> String {
  let margin = string.repeat(" ", vr.help_message_margin)
  [
    margin <> "--prettier",
    margin <> "  -> run npm prettier on emitted content",
  ]
  |> string.join("\n")
}

fn handle_parse_html_request(
  arguments: vr.ParsedCLIArguments,
) -> Result(Bool, vr.CLIError) {
  case dict.get(arguments.user_args, "--parse-html") {
    Ok([path]) -> {
      html_to_writerly.html_to_writerly(path, arguments)
      Ok(True)
    }
    Ok([]) -> Error(vr.ClientSideError("please provide path to html input"))
    Ok(_) ->
      Error(vr.ClientSideError("option '--parse-html' accepts exactly one path"))
    Error(_) -> Ok(False)
  }
}

fn handle_cli_error(error: vr.CLIError) -> Nil {
  io.println("command line error: " <> vr.cli_error_message(error))
  io.println("")
}

pub fn main() {
  io.println("")

  let args = argv.load().arguments

  use args <- on.error_ok(vr.read_from_dot_last_command(args), handle_cli_error)

  use arguments <- on.error_ok(
    vr.process_command_line_arguments(args, ["--parse-html", "--prettier"]),
    handle_cli_error,
  )

  use help_requested <- on.error_ok(
    vr.handle_help_requests(arguments, cli_usage_supplementary),
    handle_cli_error,
  )

  use maintenance_requested <- on.error_ok(
    vr.handle_maintenance_requests(arguments, local_desugarers.assertive_tests),
    handle_cli_error,
  )

  use _ <- on.stay(case maintenance_requested || help_requested {
    True -> on.Return(Nil)
    False -> on.Stay(Nil)
  })

  use formatting_requested <- on.error_ok(
    handle_parse_html_request(arguments),
    handle_cli_error,
  )

  use _ <- on.stay(case formatting_requested {
    True -> on.Return(Nil)
    False -> on.Stay(Nil)
  })

  use _ <- on.error_ok(vr.write_to_dot_last_command(args), handle_cli_error)

  {
    let parameters =
      vr.RendererParameters(
        input_dir: "./wly_content",
        output_dir: "./output",
        prettifier_behavior: vr.PrettifierOff,
      )
      |> vr.amend_renderer_parameters_by_arguments(arguments)

    let options =
      vr.vanilla_options()
      |> vr.amend_renderer_options_by_arguments(arguments)

    let renderer =
      vr.Renderer(
        assembler: wd.default_writerly_assembler(_, options),
        filterer: vr.default_filterer(_, options, []),
        parser: wd.default_writerly_parser,
        pipeline: pipeline.our_pipeline(),
        splitter: our_splitter,
        emitter: ti2_emitter,
        writer: vr.default_writer,
        prettifier: vr.empty_prettifier,
      )

    case vr.run_renderer(renderer, parameters, options) {
      Error(error) -> io.println("renderer error: " <> ins(error) <> "\n")
      _ -> Nil
    }
  }
}
