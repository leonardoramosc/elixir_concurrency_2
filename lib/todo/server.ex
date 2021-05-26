defmodule Todo.Server do
  use GenServer, restart: :temporary

  @impl true
  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()} }
  end

  @impl true
  def handle_call({:entries, date}, _from, {name, todolist}) do
    entries = Todo.List.entries(todolist, date)
    {
      :reply,
      entries,
      {name, todolist}
    }
  end

  @impl true
  def handle_cast({:add_entry, entry}, {name, todolist}) do
    new_todolist = Todo.List.add_entry(todolist, entry)

    Todo.Database.store(name, new_todolist)

    {:noreply, {name, new_todolist}}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple(name)
  end
end
