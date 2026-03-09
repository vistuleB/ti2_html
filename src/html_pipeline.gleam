import infrastructure as infra
import desugarer_library as dl

pub fn html_pipeline() -> infra.Pipeline {
  [
    dl.identity(),
    // dl.ii2_remove_chapter_number_from_title(),
    dl.trim_spaces_around_newlines__outside(["pre"]),
    dl.replace_multiple_spaces_by_one(),
    dl.extract_starting_and_ending_spaces(["i", "b", "strong", "em", "code"]),
    dl.insert_bookend_text_if_no_attributes([
      #("i", "_", "_"),
      #("em", "_", "_"),
      #("b", "*", "*"),
      #("strong", "*", "*"),
      #("code", "`", "`"),
    ]),
    dl.surround_elements_by(#(["i", "b", "strong", "em", "code"], "go23_xU", "go23_xU")),
    dl.unwrap_tags_if_no_attributes(["i", "b", "strong", "em", "code"]),
    dl.fold_into_text(#("go23_xU", "")),
    dl.delete_empty_lines(),
    dl.find_replace__batch__outside([#("&amp;", "&"), #("&lt;", "<"), #("&gt;", ">"), #("&ensp;", "\\ ")], []),
    dl.add_between(#("p", "p", "WriterlyBlankLine")),
    dl.unwrap("p"),
    dl.ii2_class_well_container_theorem_2_statement(),
    dl.ii2_div_class_subchpater_2_sub(),
    dl.nuke_ancestors("Sub"),
  ]
  |> infra.desugarers_2_pipeline()
}
