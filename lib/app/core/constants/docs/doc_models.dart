/// One page of the in-site documentation, shown at `/docs/<id>`.
///
/// [body] is written in the small Markdown subset that `MarkdownView`
/// renders:
///
/// - `## Heading` and `### Heading` (no `#`; the page title is [title]).
///   `##` headings also build the page's "On this page" list.
/// - Paragraphs: consecutive lines, separated by a blank line.
/// - Bullet lists (`- item`) and numbered lists (`1. item`). A line indented
///   by two spaces continues the item above it. No nesting.
/// - Fenced code: a line of three backticks plus a language (`dart`, `yaml`,
///   `bash`, `json` or `text`), optionally followed by a title, such as
///   `lib/main.dart`. Close it with three backticks.
/// - Callouts: lines starting with `> `. Start the first with `**Note:**`,
///   `**Tip:**` or `**Warning:**` to pick the style.
/// - Tables: `| a | b |` rows; the second row is the `|---|---|` separator.
/// - Inline: `code`, **bold** and [text](url). A url starting with `/` is a
///   page of this site (`/docs/ecs`, `/editor`, `/cli`); anything else opens
///   in a new tab.
class DocPage {
  const DocPage({
    required this.id,
    required this.title,
    required this.group,
    required this.summary,
    required this.body,
    this.keywords = const [],
  });

  /// URL slug: the page lives at `/docs/<id>`.
  final String id;

  /// Shown as the page heading and in the sidebar.
  final String title;

  /// One of [DocGroups]; decides where the page sits in the sidebar.
  final String group;

  /// One sentence shown under the title and matched by search.
  final String summary;

  /// The page content, in the Markdown subset described above.
  final String body;

  /// Extra search terms, such as the class names the page covers.
  final List<String> keywords;
}

/// Sidebar groups, in display order.
abstract final class DocGroups {
  static const gettingStarted = 'Getting started';
  static const tools = 'Tools';
  static const core = 'Core';
  static const graphics = 'Graphics';
  static const gameplay = 'Gameplay';
  static const audioContent = 'Audio & content';
  static const flutter = 'Flutter & shipping';

  static const order = [
    gettingStarted,
    tools,
    core,
    graphics,
    gameplay,
    audioContent,
    flutter,
  ];
}
