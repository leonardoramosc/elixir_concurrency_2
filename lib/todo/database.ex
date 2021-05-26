# Esta base de datos, es un proceso que hace uso de 3 database_workers
# de modo que estos 3 workers podran manipular la base de datos de forma concurrente
# Esto se podria ser que es un pool. Es decir, este modulo, delega las operaciones
# de la base de datos a 3 procesos.

defmodule Todo.Database do

  @pool_size 3
  @db_folder "./persist"

  def start_link() do
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec/1)

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp worker_spec(worker_id) do
    # especificacion por defecto del databaseworker, se le pasa el nombre del modulo
    # y el parametro que recibira la funcion start_link de los database_workers.
    default_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    # Se cambia el child_spec del database_worker, para darle un identificador unico
    # con el parametro worker_id, esto es para que el supervisor tome cada database_worker
    # como un proceso distinto.
    Supervisor.child_spec(default_spec, id: worker_id)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  def choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
