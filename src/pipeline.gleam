import gleam/list
import infrastructure as infra
import prefabricated_pipelines as pp
import desugarer_library as dl

pub fn our_pipeline() -> infra.Pipeline {
  [
    [
      dl.find_replace__outside(#("&ensp;", " "), [])
    ],
    // pp.normalize_begin_end_align(infra.DoubleDollar),
    pp.create_mathblock_elements([infra.DoubleDollar], infra.DoubleDollar),
    pp.create_math_elements([infra.BackslashParenthesis], infra.BackslashParenthesis, infra.BackslashParenthesis),
    [
      dl.append_attribute(#("Book", "counter", "BookLevelSectionCounter", infra.GoBack)),
      dl.prepend_counter_incrementing_attribute(#("section", "BookLevelSectionCounter", infra.GoBack)),
      dl.append_attribute(#("section", "path", "/lecture-notes::øøBookLevelSectionCounter", infra.GoBack)),
      dl.unwrap("WriterlyBlankLine"),
      dl.concatenate_text_nodes(),
    ],
    pp.symmetric_delim_splitting("`", "`", "code", ["MathBlock", "Math", "code"]),
    pp.symmetric_delim_splitting("_", "_", "i", ["MathBlock", "Math", "code"]),
    pp.symmetric_delim_splitting("\\*", "*", "b", ["MathBlock", "Math", "code"]),
    [
      dl.counters_substitute_and_assign_handles(),
      dl.handles_add_ids(),
      dl.handles_generate_dictionary_and_id_list("path"),
      dl.identity(),
      // dl.handles_substitute(),
      dl.concatenate_text_nodes(),
      dl.unwrap_if_no_child_meets_condition(#("p", infra.is_text_or_is_one_of(_, ["b", "i", "a", "span"]))),
      dl.unwrap_if_child_of__batch([#("p", ["span", "code", "tt", "figcaption", "em"])]),
      dl.free_children__batch([#("pre", "p"), #("ul", "p"), #("ol", "p"), #("p", "p"), #("figure", "p")]),
      dl.ii2_generate_table_of_contents_html(#("TOCAuthorSuppliedContent", "li")),
      dl.fold_into_text__batch([#("MathBlock", ""), #("Math", ""), #("MathDollar", "")]),
    ]
  ]
  |> list.flatten
  |> infra.desugarers_2_pipeline
}
