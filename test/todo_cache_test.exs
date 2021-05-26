defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "bob")

    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  test "todo operations" do
    {:ok, cache} = Todo.Cache.start()
    leo = Todo.Cache.server_process(cache, "leo")
    entry = %{date: ~D[2018-12-19], title: "Dentist"}
    Todo.Server.add_entry(leo, entry)
    entries = Todo.Server.entries(leo, entry.date)

    assert entries == [Map.put(entry, :id, 1)]
  end

end
