alias RoundestPhoenix.Repo
alias RoundestPhoenix.Content.Entry

Repo.delete_all(Entry)

sample_urls = [
  "https://bg.image.engineering/?image=https%3A%2F%2Futfs.io%2Fa%2Fbsqdevxuwl%2FIDWGSvlwlJtcJ7SQWwgTmQCGsgUcRqAJuznO9foPVrDvBbM6",
  "https://bg.image.engineering/?image=https%3A%2F%2Futfs.io%2Fa%2Fbsqdevxuwl%2FIDWGSvlwlJtcen927zcIQ0UcR8v9ZwzV7TfHjK4GAC12FJgs",
  "https://bg.image.engineering/?image=https%3A%2F%2Futfs.io%2Fa%2Fbsqdevxuwl%2FIDWGSvlwlJtcs2AqwZdine8LXW4a2ZlNrjKJpmgYVvAI1xD6",
  "https://bg.image.engineering/?image=https%3A%2F%2Futfs.io%2Fa%2Fbsqdevxuwl%2FIDWGSvlwlJtc2CKSJQhmNKzLyfvJxIPAFn0leMhrGOcRHkj9",
  "https://bg.image.engineering/?image=https%3A%2F%2Futfs.io%2Fa%2Fbsqdevxuwl%2FIDWGSvlwlJtcuixX44IJOdhNP96sVvxACeU7KH3BYbmZWoap",
  "https://bg.image.engineering/?image=https%3A%2F%2Futfs.io%2Fa%2Fbsqdevxuwl%2FIDWGSvlwlJtct2VZVfQjYdnWmzaOXrpf2MUGsbv4gPR3t09C",
  "https://bg.image.engineering/?image=https%3A%2F%2Futfs.io%2Fa%2Fbsqdevxuwl%2FIDWGSvlwlJtcchUyCX0Gv8XtYSAb43sLgxHapZIzuMTPlNQm",
  "https://bg.image.engineering/?image=https%3A%2F%2Futfs.io%2Fa%2Fbsqdevxuwl%2FIDWGSvlwlJtcKyDoM7CrNG2lbDE5MWRzojmA9efVkhwn4876"
]

Enum.each(sample_urls, fn url ->
  Repo.insert!(%Entry{
    url: url,
    up_vote: 0,
    down_vote: 0
  })
end)
