// This function gets your whole document as its `body`
// and formats it as a simple letter.
#let letter(
  // The letter's sender, which is display at the top of the page.
  sender: none,

  // The letter's recipient, which is displayed close to the top.
  recipient: none,

  // The date, displayed to the right.
  date: none,

  // The subject line.
  subject: none,

  // The name with which the letter closes.
  name: none,

  // The letter's content.
  body
) = {
  // Configure page and text properties.
  set page(margin: (top: 2cm))
  set text(font: "Inconsolata")
  set text(10pt)

  let cell = rect.with(
    fill: rgb("ffffff"),
  )
  grid(
    columns: (120pt, 1fr),
    rows: (60pt, auto),
    cell(height: 100%)[#image("logo-w3c.svg")],
    cell(height: 100%)[
      Line 1 \
      Line 2 \
      Line 3 \
      Line 4
    ],
  )

  // Display sender at top of page. If there's no sender
  // add some hidden text to keep the same spacing.
  text(9pt, if sender == none {
    hide("a")
  } else {
    sender
  })

  v(1.8cm)

  // Display recipient.
  recipient

  v(0.5cm)

  // Display date. If there's no date add some hidden
  // text to keep the same spacing.
  align(right, if date != none {
    date
  } else {
    hide("a")
  })

  v(2cm)

  // Add the subject line, if any.
  if subject != none {
    pad(right: 10%, strong(subject))
  }

  // Add body and name.
  body
  v(1.25cm)
  name
}
