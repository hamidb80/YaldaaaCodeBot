import std/strformat

func escapeMarkdownV2*(s: string): string =
    result = newStringOfCap(s.len * 2)
    for c in s:
        if c in "_*[]()~`>#+-=|{}.!\\":
            result.add '\\'

        result.add c

func bold*(s: string): string = fmt"*{s}*"
func italic*(s: string): string = fmt"_{s}_"
func underline*(s: string): string = fmt"__{s}__"
func link*(url, label: string): string = fmt"[{url}]({label})"
func spoiler*(s: string): string = fmt"||{s}||"
func inlineCode*(s: string): string = fmt"`{s}`"
func code*(s: string): string = fmt"```{s}```"

func wrapString*(s: string): string = fmt "\"{s}\""
