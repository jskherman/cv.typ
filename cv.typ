#import "utils.typ"

// set rules
#let setrules(uservars, doc) = {
  set text(font: uservars.bodyfont, size: uservars.fontsize, hyphenate: false)
  set list(spacing: uservars.linespacing)
  set par(leading: uservars.linespacing, justify: true)

  doc
}

// show rules
#let showrules(uservars, doc) = {
  // uppercase section headings
  show heading.where(level: 2): it => block(width: 100%, {
    set align(left)
    set text(font: uservars.headingfont, size: 1em, weight: "bold")

    if (uservars.at("headingsmallcaps", default: false)) {
      smallcaps(it.body)
    } else {
      upper(it.body)
    }

    v(-0.5em)
    line(length: 100%, stroke: 1pt + black)
  })

  // name title
  show heading.where(level: 1): it => block(width: 100%, {
    set text(font: uservars.headingfont, size: 1.5em, weight: "bold")

    if (uservars.at("headingsmallcaps", default: false)) {
      smallcaps(it.body)
    } else {
      upper(it.body)
    }

    v(0.1em)
  })

  doc
}

// set page layout
#let cvinit(doc) = {
  doc = setrules(doc)
  doc = showrules(doc)

  doc
}

#let line_one(left: none, right: none, url: none) = {
  if url != none {
    if right != none {
      [*#link(url, left)* #h(1fr) *#right*]
    } else {
      [*#link(url, left)* #h(1fr)]
    }
  } else {
    if right != none {
      [*#left* #h(1fr) *#right*]
    } else {
      [*#left* #h(1fr)]
    }
  }
}

#let line_two(left: none, right_start: none, right_end: none) = {
  if right_end != none {
    [#text(style: "italic", left) #h(1fr) #right_start #sym.dash.en #right_end]
  } else {
    [#text(style: "italic", left) #h(1fr) #right_start]
  }
}

#let dot_list(title, elements, url: none) = {
  if url != none {
    [- *#link(url, title)*: #elements.join(", ")]
  } else {
    [- *#title*: #elements.join(", ")]
  }
}

// address
#let addresstext(info, uservars) = {
  if uservars.showAddress {
    let address_line = ()
    let location = info.personal.at("location")

    for key in ("city", "region", "country") {
      let value = location.at(key, default: none)
      if value != none and value != "" {
        address_line.push([#location.at(key, default: none)])
      }
    }

    [#address_line.join(", ") #location.postalCode]

    v(-0.5em)
  }
}

#let contacttext(info, uservars) = block(
  width: 100%, {
    let profiles = array(
      (
        box(link("mailto:" + info.personal.email)), if uservars.showNumber { box(link("tel:" + info.personal.phone)) } else { none }, if info.at("personal.url", default: none) != none { box(link(info.personal.url, { info.personal.url.split("//").at(1) })) },
      ).filter(it => it != none),
    ) // remove empty elements from profiles

    if info.personal.profiles.len() > 0 {
      for profile in info.personal.profiles {
        profiles.push(box(link(profile.url, { profile.url.split("//").at(1) })))
      }
    }

    set text(font: uservars.bodyfont, weight: "medium", size: uservars.fontsize * 1)
    pad(x: 0em, {
      profiles.join([#sym.space.en #sym.diamond.filled #sym.space.en])
    })
  },
)

#let cvheading(info, uservars) = {
  align(center, {
    [= #info.personal.name]

    addresstext(info, uservars)
    contacttext(info, uservars)
  })
}

#let cvwork(info, isbreakable: true) = {
  if info.at("work", default: none) != none {
    block({
      [== Work Experience]

      for w in info.work {
        let company = w.organization
        let url = w.at("url", default: none)
        let location = w.location

        line_one(left: company, right: location, url: url)

        let index = 0
        for p in w.positions {
          let start = utils.strpdate(p.startDate)
          let end = utils.strpdate(p.endDate)

          if index != 0 { v(0.5em) }

          block(above: 0.5em, {
            line_two(left: p.position, right_start: start, right_end: end)
          })

          for hi in p.highlights {
            [- #hi]
          }

          index = index + 1
        }
      }
    })
  }
}

#let cveducation(info, isbreakable: true) = {
  if info.at("education", default: none) != none {
    block({
      [== Education]

      for edu in info.education {
        let start = utils.strpdate(edu.startDate)
        let end = utils.strpdate(edu.endDate)

        let left = [#edu.studyType in #edu.area]
        let url = edu.at("url", default: none)

        block(width: 100%, breakable: isbreakable, {
          // line 1: institution and location
          line_one(left: edu.institution, right: edu.location, url: edu.url)
          linebreak()
          // line 2: degree and date
          line_two(left: left, right_start: start, right_end: end)
          let honors = edu.at("honors", default: ())
          dot_list("Honors", honors)

          let courses = edu.at("courses", default: ())
          dot_list("Courses", courses)

          if edu.at("highlights", default: none) != none {
            for h in edu.highlights {
              [- #eval(h, mode: "markup")]
            }
          }
        })
      }
    })
  }
}

#let cvaffiliations(info, isbreakable: true) = {
  if info.at("affiliations", default: none) != none {
    block(
      {
        [== Leadership & Activities]

        for org in info.affiliations {
          let url = org.at("url", default: none)
          let start = utils.strpdate(org.startDate)
          let end = utils.strpdate(org.endDate)

          block(width: 100%, breakable: isbreakable, {
            // line 1: organization and location
            line_one(left: org.organization, right: org.location, url: org.url)

            linebreak()
            // line 2: position and date
            line_two(left: org.position, right_start: start, right_end: end)

            if org.at("highlights", default: none) != none {
              for h in org.highlights {
                [- #h]
              }
            }
          })
        }
      },
    )
  }
}

#let cvprojects(info, isbreakable: true) = {
  if info.at("projects", default: none) != none {
    block(
      {
        [== Projects]

        for project in info.projects {
          let url = project.at("url", default: none)
          let start = utils.strpdate(project.startDate)
          let end = utils.strpdate(project.endDate)

          block(
            width: 100%, breakable: isbreakable, {
              // line 1: project name
              line_one(left: project.name, url: url)

              linebreak()
              // line 2: organization and date
              line_two(left: project.affiliation, right_start: start, right_end: end)

              for h in project.highlights {
                [- #h]
              }
            },
          )
        }
      },
    )
  }
}

#let cvawards(info, isbreakable: true) = {
  if info.at("awards", default: none) != none {
    block({
      [== Honors & Awards]
      for award in info.awards {
        let url = award.at("url", default: none)
        let date = utils.strpdate(award.date)

        block(width: 100%, breakable: isbreakable, {
          // line 1: award title and location
          line_one(left: award.title, right: award.location, url: url)

          linebreak()
          // line 2: issuer and date
          line_two(left: award.issuer, right_start: date)

          if award.at("highlights", default: none) != none {
            for h in award.highlights {
              [- #h]
            }
          }
        })
      }
    })
  }
}

#let cvcertificates(info, isbreakable: true) = {
  if info.at("certificates", default: none) != none {
    block({
      [== Licenses & Certifications]

      for cert in info.certificates {
        let url = cert.at("url", default: none)
        let date = utils.strpdate(cert.date)

        block(width: 100%, breakable: isbreakable, {
          // line 1: certificate name
          line_one(left: cert.name, url: cert.url)

          linebreak()
          // line 2: issuer and date
          line_two(left: cert.issuer, right_start: date)
        })
      }
    })
  }
}

#let cvpublications(info, isbreakable: true) = {
  if info.at("publications", default: none) != none {
    block({
      [== Research & Publications]

      for pub in info.publications {
        let url = pub.at("url", default: none)
        let date = utils.strpdate(pub.releaseDate)

        block(width: 100%, breakable: isbreakable, {
          // line 1: publication title
          line_one(left: pub.name, url: url)

          linebreak()
          // line 2: publisher and date
          [Published on #line_two(left: pub.publisher, right_start: date)]
        })
      }
    })
  }
}

#let cvskills(info, isbreakable: true) = {
  if (info.at("languages", default: none) != none) or (info.at("skills", default: none) != none) or (info.at("interests", default: none) != none) {
    block(breakable: isbreakable, {
      [== Skills, Languages, Interests]

      let langs = info.at("languages", default: none)
      let langs_join = ()
      for lang in langs {
        langs_join.push([#lang.language (#lang.fluency)])
      }

      dot_list("Languages", langs_join)

      let skills = info.at("skills", default: none)
      for skill in skills {
        dot_list(skill.category, skill.skills)
      }

      let interests = info.at("interests", default: none)
      dot_list("Interests", interests)
    })
  }
}

#let cvreferences(info, isbreakable: true) = {
  if info.at("references", default: none) != none {
    block({
      [== References]

      for ref in info.references {
        let foo = ()
        foo.push(ref.reference)
        dot_list(ref.name, foo, url: ref.url)
      }
    })
  }
}

#let endnote() = {
  place(
    bottom + right, block(
      {
        text(
          size: 4pt, font: "Consolas", fill: silver, {
            [This document was last updated on #datetime.today().display("[year]-[month]-[day]") using #strike[LaTeX] #link("https://typst.app/docs")[Typst]]
          },
        )
      },
    ),
  )
}
