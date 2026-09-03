import gleam/list
import local_desugarers as local_dl
import vxml_pipeline/core as infra
import vxml_pipeline/delimiter_pipelines as syntax
import vxml_pipeline/desugarers as dl

pub fn our_pipeline() -> infra.Pipeline {
  [
    [dl.find_replace__outside(#("&ensp;", " "), [])],
    // syntax.normalize_begin_end_align(infra.DoubleDollar),
    syntax.math_block_pipeline(
      [infra.DoubleDollar],
      infra.DoubleDollar,
      [
        "WriterlyBlankLine",
      ],
      [],
    ),
    syntax.inline_math_pipeline(
      [infra.BackslashParenthesis],
      infra.BackslashParenthesis,
      infra.BackslashParenthesis,
      ["WriterlyBlankLine"],
      [],
    ),
    [
      dl.append_attribute(#(
        "Book",
        "counter",
        "BookLevelSectionCounter",
        infra.GoBack,
      )),
      dl.sigil_counters_prepend_incrementing_attribute(#(
        "section",
        "BookLevelSectionCounter",
        infra.GoBack,
      )),
      dl.append_attribute(#(
        "section",
        "path",
        "/lecture-notes::øøBookLevelSectionCounter",
        infra.GoBack,
      )),
      dl.unwrap("WriterlyBlankLine"),
      dl.concatenate_text_nodes(),
    ],
    syntax.boundary_aware_symmetric_delimiter_pipeline("`", "`", "code", [
      "MathBlock",
      "Math",
      "code",
    ]),
    syntax.boundary_aware_symmetric_delimiter_pipeline("_", "_", "i", [
      "MathBlock",
      "Math",
      "code",
    ]),
    syntax.boundary_aware_symmetric_delimiter_pipeline("\\*", "*", "b", [
      "MathBlock",
      "Math",
      "code",
    ]),
    [
      dl.sigil_counters_substitute__outside(["pre"]),
      dl.writerly_handles_add_ids(),
      dl.writerly_handles_grand_wrapper_generate_dictionary("path"),
      dl.identity(),
      // dl.writerly_handles_grand_wrapper_substitute(),
      dl.concatenate_text_nodes(),
      dl.unwrap_if_no_child_meets_condition(
        #("p", infra.is_t_or_is_one_of(_, ["b", "i", "a", "span"])),
      ),
      dl.unwrap_if_child_of__batch([
        #("p", ["span", "code", "tt", "figcaption", "em"]),
      ]),
      dl.free_children__batch([
        #("pre", "p"),
        #("ul", "p"),
        #("ol", "p"),
        #("p", "p"),
        #("figure", "p"),
      ]),
      local_dl.ii2_generate_table_of_contents_html(#(
        "TOCAuthorSuppliedContent",
        "li",
      )),
      dl.fold_into_text__batch([
        #("MathBlock", ""),
        #("Math", ""),
        #("MathDollar", ""),
      ]),
    ],
  ]
  |> list.flatten
}
