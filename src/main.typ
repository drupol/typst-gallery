#import "template.typ": *
#show: letter.with(
  recipient: [
    Mr. Foo Bar \
    1000 Bruxelles
  ],
  date: [Bruxelles, 27 mars 2023],
  subject: [Letter example],
  name: [Director]
)

Dear Joe,

#lorem(99)

Best,

#image("signature.svg", width: 30%)

