#import "utils.typ"

// Load CV Data from YAML
//#let info = yaml("cv.typ.yml")

// Variables
//#let headingfont = "Linux Libertine" // Set font for headings
//#let bodyfont = "Linux Libertine"   // Set font for body
//#let fontsize = 10pt // 10pt, 11pt, 12pt
//#let linespacing = 6pt
//#let headingsmallcaps = false

//#let showAddress = true // true/false Show address in contact info
//#let showNumber = true  // true/false Show phone number in contact info

// set rules
#let setrules(uservars, doc) = {
    // set page(
    //     paper: "us-letter", // a4, us-letter
    //     numbering: "1 / 1",
    //     number-align: center, // left, center, right
    //     margin: 1.25cm, // 1.25cm, 1.87cm, 2.5cm
    // )

    // Set Text settings
    set text(
        font: uservars.bodyfont,
        size: uservars.fontsize,
        hyphenate: false,
    )

    set list(
        spacing: uservars.linespacing
    )

    // Set Paragraph settings
    set par(
        leading: uservars.linespacing,
        justify: true,
    )

    doc
}

// show rules
#let showrules(uservars, doc) = {
    // Uppercase Section Headings
    show heading.where(
        level: 2,
    ): it => block(width: 100%)[
        #set align(left)
        #set text(font: uservars.headingfont, size: 1em, weight: "bold")
        #if (uservars.at("headingsmallcaps", default:false)) {
            smallcaps(it.body)
        } else {
            upper(it.body)
        }
        #v(-0.75em) #line(length: 100%, stroke: 1pt + black) // Draw a line
    ]

    // Name Title
    show heading.where(
        level: 1,
    ): it => block(width: 100%)[
        #set text(font: uservars.headingfont, size: 1.5em, weight: "bold")
        #if (uservars.at("headingsmallcaps", default:false)) {
            smallcaps(it.body)
        } else {
            upper(it.body)
        }
        #v(2pt)
    ]

    doc
}

// Set Page Layout
#let cvinit(doc) = {
    doc = setrules(doc)
    doc = showrules(doc)

    doc
}

// Address
#let addresstext(info, uservars) = {
    if uservars.showAddress {
        block(width: 100%)[
            #info.personal.location.city, #info.personal.location.region, #info.personal.location.country #info.personal.location.postalCode
            #v(-4pt)
        ]
    } else {none}
}

// Arrange the contact profiles with a diamond separator
#let contacttext(info, uservars) = block(width: 100%)[
    // Contact Info
    // Create a list of contact profiles
    #let profiles = (
        box(link("mailto:" + info.personal.email)),
        if uservars.showNumber {box(link("tel:" + info.personal.phone))} else {none},
        if info.personal.url != none {
            box(link(info.personal.url)[#info.personal.url.split("//").at(1)])
        }
    ).filter(it => it != none) // Filter out none elements from the profile array

    // Add any social profiles
    #if info.personal.profiles.len() > 0 {
        for profile in info.personal.profiles {
            profiles.push(
                box(link(profile.url)[#profile.url.split("//").at(1)])
            )
        }
    }

    // #set par(justify: false)
    #set text(font: uservars.bodyfont, weight: "medium", size: uservars.fontsize * 1)
    #pad(x: 0em)[
        #profiles.join([#sym.space.en #sym.diamond.filled #sym.space.en])
    ]
]

// Create layout of the title + contact info
#let cvheading(info, uservars) = {
    align(center)[
        = #info.personal.name
        #addresstext(info, uservars)
        #contacttext(info, uservars)
        // #v(0.5em)
    ]
}

// Education
#let cveducation(info, isbreakable: true) = {
    if info.education != none {block[
        == Education
        #for edu in info.education {
            // Parse ISO date strings into datetime objects
            let start = utils.strpdate(edu.startDate)
            let end = utils.strpdate(edu.endDate)

            let edu-items = ""
            if edu.honors != none {edu-items = edu-items + "- *Honors*: " + edu.honors.join(", ") + "\n"}
            if edu.courses != none {edu-items = edu-items + "- *Courses*: " + edu.courses.join(", ") + "\n"}
            if edu.highlights != none {
                for hi in edu.highlights {
                    edu-items = edu-items + "- " + hi + "\n"
                }
                edu-items = edu-items.trim("\n")
            }

            // Create a block layout for each education entry
            block(width: 100%, breakable: isbreakable)[
                // Line 1: Institution and Location
                #if edu.url != none [
                    *#link(edu.url)[#edu.institution]* #h(1fr) *#edu.location* \
                ] else [
                    *#edu.institution* #h(1fr) *#edu.location* \
                ]
                // Line 2: Degree and Date Range
                #text(style: "italic")[#edu.studyType in #edu.area] #h(1fr)
                #start #sym.dash.en #end \
                #eval(edu-items, mode: "markup")
            ]
        }
    ]}
}

// Work Experience
#let cvwork(info, isbreakable: true) = {
    if info.work != none {block[
        == Work Experience
        #for w in info.work {
            // Parse ISO date strings into datetime objects
            let start = utils.strpdate(w.startDate)
            let end = utils.strpdate(w.endDate)
            // Create a block layout for each education entry
            block(width: 100%, breakable: isbreakable)[
                // Line 1: Institution and Location
                #if w.url != none [
                    *#link(w.url)[#w.organization]* #h(1fr) *#w.location* \
                ] else [
                    *#w.organization* #h(1fr) *#w.location* \
                ]
                // Line 2: Degree and Date Range
                #text(style: "italic")[#w.position] #h(1fr)
                #start #sym.dash.en #end \
                // Highlights or Description
                #for hi in w.highlights [
                    - #eval(hi, mode: "markup")
                ]
            ]
        }
    ]}
}

// Leadership and Activities
#let cvaffiliations(info, isbreakable: true) = {
    if info.affiliations != none {block[
        == Leadership & Activities
        #for org in info.affiliations {
            // Parse ISO date strings into datetime objects
            let start = utils.strpdate(org.startDate)
            let end = utils.strpdate(org.endDate)

            // Create a block layout for each education entry
            block(width: 100%, breakable: isbreakable)[
                // Line 1: Institution and Location
                #if org.url != none [
                    *#link(org.url)[#org.organization]* #h(1fr) *#org.location* \
                ] else [
                    *#org.organization* #h(1fr) *#org.location* \
                ]
                // Line 2: Degree and Date Range
                #text(style: "italic")[#org.position] #h(1fr)
                #start #sym.dash.en #end \
                // Highlights or Description
                #if org.highlights != none {
                    for hi in org.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                } else {}
            ]
        }
    ]}
}

// Projects
#let cvprojects(info, isbreakable: true) = {
    if info.projects != none {block[
        == Projects
        #for project in info.projects {
            // Parse ISO date strings into datetime objects
            let start = utils.strpdate(project.startDate)
            let end = utils.strpdate(project.endDate)
            // Create a block layout for each education entry
            block(width: 100%, breakable: isbreakable)[
                // Line 1: Institution and Location
                #if project.url != none [
                    *#link(project.url)[#project.name]* \
                ] else [
                    *#project.name* \
                ]
                // Line 2: Degree and Date Range
                #text(style: "italic")[#project.affiliation]  #h(1fr) #start #sym.dash.en #end \
                // Summary or Description
                #for hi in project.highlights [
                    - #eval(hi, mode: "markup")
                ]
            ]
        }
    ]}
}

// Honors and Awards
#let cvawards(info, isbreakable: true) = {
    if info.awards != none {block[
        == Honors & Awards
        #for award in info.awards {
            // Parse ISO date strings into datetime objects
            let date = utils.strpdate(award.date)
            // Create a block layout for each education entry
            block(width: 100%, breakable: isbreakable)[
                // Line 1: Institution and Location
                #if award.url != none [
                    *#link(award.url)[#award.title]* #h(1fr) *#award.location* \
                ] else [
                    *#award.title* #h(1fr) *#award.location* \
                ]
                // Line 2: Degree and Date Range
                Issued by #text(style: "italic")[#award.issuer]  #h(1fr) #date \
                // Summary or Description
                #if award.highlights != none {
                    for hi in award.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                } else {}
            ]
        }
    ]}
}

// Certifications
#let cvcertificates(info, isbreakable: true) = {
    if info.certificates != none {block[
        == Licenses & Certifications

        #for cert in info.certificates {
            // Parse ISO date strings into datetime objects
            let date = utils.strpdate(cert.date)
            // Create a block layout for each education entry
            block(width: 100%, breakable: isbreakable)[
                // Line 1: Institution and Location
                #if cert.url != none [
                    *#link(cert.url)[#cert.name]* \
                ] else [
                    *#cert.name* \
                ]
                // Line 2: Degree and Date Range
                Issued by #text(style: "italic")[#cert.issuer]  #h(1fr) #date \
            ]
        }
    ]}
}

// Research & Publications
#let cvpublications(info, isbreakable: true) = {
    if info.publications != none {block[
        == Research & Publications
        #for pub in info.publications {
            // Parse ISO date strings into datetime objects
            let date = utils.strpdate(pub.releaseDate)
            // Create a block layout for each education entry
            block(width: 100%, breakable: isbreakable)[
                // Line 1: Institution and Location
                #if pub.url != none [
                    *#link(pub.url)[#pub.name]* \
                ] else [
                    *#pub.name* \
                ]
                // Line 2: Degree and Date Range
                Published on #text(style: "italic")[#pub.publisher]  #h(1fr) #date \
            ]
        }
    ]}
}

// Skills, Languages, and Interests
#let cvskills(info, isbreakable: true) = {
    if (info.languages != none) or (info.skills != none) or (info.interests != none) {block(breakable: isbreakable)[
        == Skills, Languages, Interests
        #if (info.languages != none) [
            #let langs = ()
            #for lang in info.languages {
                langs.push([#lang.language (#lang.fluency)])
            }
            - *Languages*: #langs.join(", ")
        ]
        #if (info.skills != none) [
            #for group in info.skills [
                - *#group.category*: #group.skills.join(", ")
            ]
        ]
        #if (info.interests != none) [
            - *Interests*: #info.interests.join(", ")
        ]
    ]}
}

// References
#let cvreferences(info, isbreakable: true) = {
    if info.references != none {block[
        == References
        #for ref in info.references {
            block(width: 100%, breakable: isbreakable)[
                #if ref.url != none [
                    - *#link(ref.url)[#ref.name]*: "#ref.reference"
                ] else [
                    - *#ref.name*: "#ref.reference"
                ]
            ]
        }
    ]} else {}
}

// #cvreferences

// =====================================================================

// End Note
#let endnote = {
    place(
        bottom + right,
        block[
            #set text(size: 5pt, font: "Consolas", fill: silver)
            \*This document was last updated on #datetime.today().display("[year]-[month]-[day]") using #strike[LaTeX] #link("https://typst.app")[Typst].
        ]
    )
}

// #place(
//     bottom + right,
//     dy: -71%,
//     dx: 4%,
//     rotate(
//         270deg,
//         origin: right + horizon,
//         block(width: 100%)[
//             #set align(left)
//             #set par(leading: 0.5em)
//             #set text(size: 6pt)

//             #super(sym.dagger) This document was last updated on #raw(datetime.today().display("[year]-[month]-[day]")) using #strike[LaTeX] #link("https://typst.app")[Typst].
//             // Template by Je Sian Keith Herman.
//         ]
//     )
// )
