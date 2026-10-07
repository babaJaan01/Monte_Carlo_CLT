// Native Quarto/Typst styling: no external fonts, images or design packages.
#set document(title: "How Fast Does Normal Happen?", author: "Shayaan Tanveer")
#set text(fill: rgb("#17212B"))
#set par(justify: false, leading: 0.7em)
#set page(
  header: text(size: 8pt, fill: rgb("#667085"))[MATH 167R / MONTE CARLO],
  footer: context grid(columns: (1fr, auto),
    text(size: 8pt, fill: rgb("#667085"))[Shayaan Tanveer],
    text(size: 8pt, fill: rgb("#667085"))[#counter(page).display() / 4]),
)
#show heading: set text(fill: rgb("#17212B"), weight: "bold")
#show heading.where(level: 1): set text(size: 25pt)
#show heading.where(level: 2): set text(size: 14pt)
#set table(inset: (x: 7pt, y: 7pt), stroke: none,
  fill: (x, y) => if y == 0 { rgb("#EAF4F4") }
    else if calc.odd(y) { rgb("#F5F7FA") } else { white })
#show table.cell.where(y: 0): set text(weight: "bold", fill: rgb("#007D83"))
#show figure.caption: set text(size: 9pt, fill: rgb("#667085"))
#show link: set text(fill: rgb("#007D83"))
