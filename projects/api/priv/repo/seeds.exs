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
  Stories.Story,
  Publications,
  Tags.Tag
}

alias Publications.{Publication, PublicationMembership}

diego =
  Repo.insert!(%User{
    username: "diego",
    first_name: "Diego",
    last_name: "Stratta",
    email: "strattadb@gmail.com",
    location: "Montevideo, Uruguay",
    is_admin: true,
    is_employee: true
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

Enum.each(0..7, fn _ ->
  Repo.insert!(%Story{
    content: %{
      "blocks" => [
        %{"text" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit"},
        %{
          "text" =>
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolo
      re magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
        }
      ]
    },
    author: diego,
    unique_hash:
      :sha512
      |> :crypto.hash(UUID.uuid4())
      |> Base.encode32()
      |> String.slice(0..16)
      |> String.downcase(),
    audience: :all,
    published_at: NaiveDateTime.utc_now(),
    license: :all_rights_reserved,
    tags: [margaret_tag]
  })
end)
