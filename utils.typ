#let str_to_date(iso_date) = {
  let date = ""
  if lower(iso_date) != "present" {
    date = datetime(
      year: int(iso_date.slice(0, 4)), month: int(iso_date.slice(5, 7)), day: int(iso_date.slice(8, 10)),
    )
    date = date.display("[month repr:short]") + " " + date.display("[year repr:full]")
  } else if lower(iso_date) == "present" {
    date = "Present"
  }

  return date
}
