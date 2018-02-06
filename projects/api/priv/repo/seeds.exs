# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Margaret.Repo.insert!(%Margaret.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Margaret.{
  Repo,
  Accounts.User,
  Publications,
  Tags.Tag
}

alias Publications.{Publication, PublicationMembership}

diego =
  Repo.insert!(%User{
    username: "diego",
    email: "strattadb@gmail.com",
    location: "Montevideo, Uruguay"
  })

margaret_tag =
  Repo.insert!(%Tag{
    title: "margaret"
  })

margaret_publication =
  Repo.insert!(%Publication{
    name: "margaret",
    display_name: "Margaret",
    description: "The official Margaret publication.",
    tags: [margaret_tag]
  })

Repo.insert!(%PublicationMembership{
  member: diego,
  publication: margaret_publication,
  role: :owner
})
