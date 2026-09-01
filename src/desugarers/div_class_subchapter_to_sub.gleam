import gleam/string
import vxml.{type VXML, Attr, T, V}
import vxml_pipeline/authoring
import vxml_pipeline/core.{type Desugarer, type DesugarerTransform}
import vxml_pipeline/nodemaps_2_transform as n2t
import vxml_pipeline/testing

pub const name = "div_class_subchapter_to_sub"

/// Converts a `div.subChapter` with the expected heading
/// structure into a `Sub` carrying its extracted title.
pub fn constructor() -> Desugarer {
  authoring.no_param_desugarer(
    name: name,
    transform: inner_param_to_transform(Nil),
  )
}

type InnerParam =
  Nil

fn inner_param_to_transform(_inner: InnerParam) -> DesugarerTransform {
  let nodemap: n2t.OneToOneNoErrorNodemap = nodemap
  nodemap |> n2t.one_to_one_no_error_nodemap_2_desugarer_transform
}

fn nodemap(vxml: VXML) -> VXML {
  case vxml {
    V(_, "div", _, [V(_, "h1", _, h1_children), ..rest]) ->
      case core.v_has_class(vxml, "subChapter"), h1_children {
        True, [V(_, "span", _, [T(_, [line]), ..]), ..] ->
          V(
            authoring.blame(name, 32),
            "Sub",
            [
              Attr(
                authoring.blame(name, 36),
                "title",
                string.trim(line.content),
              ),
            ],
            rest,
          )
        _, _ -> vxml
      }
    _ -> vxml
  }
}

// 🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊
// 🌊🌊🌊 tests 🌊🌊🌊🌊
// 🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊

fn assertive_tests_data() -> List(testing.AssertiveTestDataNoParam) {
  [
    testing.data_no_param(
      source: "
                <> div
                  class=subChapter
                  <> h1
                    <> span
                      <>
                        ' A title '
                  <>
                    'contents'
                ",
      expected: "
                <> Sub
                  title=A title
                  <>
                    'contents'
                ",
    ),
  ]
}

pub fn assertive_tests() {
  testing.collection_no_param(name, assertive_tests_data(), constructor)
}
