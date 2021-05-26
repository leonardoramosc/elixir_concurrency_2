# Este modulo crea un proceso especifico para leer o escribir
# registros de la base de datos
defmodule Todo.DatabaseWorker do

  use GenServer

  def start_link({db_folder, worker_id}) do
    IO.puts("Starting database worker.")
    GenServer.start_link(
      __MODULE__,
      db_folder,
      name: via_tuple(worker_id)
    )
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  @impl true
  def init(db_folder) do
    {:ok, db_folder}
  end

  @impl true
  def handle_call({:get, key}, _, db_folder) do
    data = case File.read(file_name(key, db_folder)) do
      {:ok, content} -> :erlang.binary_to_term(content)
      _ -> nil
    end

    {:reply, data, db_folder}
  end

  @impl true
  def handle_cast({:store, key, data}, db_folder) do
    key
    |> file_name(db_folder)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  defp file_name(key, db_folder) do
    Path.join(db_folder, to_string(key))
  end

end
