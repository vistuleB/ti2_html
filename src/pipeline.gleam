import desugaring/core as infra
import desugaring/delimited_syntax as syntax
import desugaring/desugarers as dl
import gleam/list
import local_desugarers as local_dl

pub fn our_pipeline() -> infra.Pipeline {
  [
    [dl.find_replace__outside(#("&ensp;", " "), [])],
    // syntax.normalize_begin_end_align(infra.DoubleDollar),
    syntax.create_mathblock_elements([infra.DoubleDollar], infra.DoubleDollar, [
      "WriterlyBlankLine",
    ]),
    syntax.create_math_elements(
      [infra.BackslashParenthesis],
      infra.BackslashParenthesis,
      infra.BackslashParenthesis,
      ["WriterlyBlankLine"],
    ),
    [
      dl.append_attribute(#(
        "Book",
        "counter",
        "BookLevelSectionCounter",
        infra.GoBack,
      )),
      dl.prepend_counter_incrementing_attribute(#(
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
    syntax.symmetric_delimiter_pipeline("`", "`", "code", [
      "MathBlock",
      "Math",
      "code",
    ]),
    syntax.symmetric_delimiter_pipeline("_", "_", "i", [
      "MathBlock",
      "Math",
      "code",
    ]),
    syntax.symmetric_delimiter_pipeline("\\*", "*", "b", [
      "MathBlock",
      "Math",
      "code",
    ]),
    [
      dl.counters_substitute_and_assign_handles(),
      dl.handles_add_ids(),
      dl.handles_grand_wrapper_generate_dictionary("path"),
      dl.identity(),
      // dl.handles_grand_wrapper_substitute(),
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
