# Este modulo, se encarga de crear un proceso por cada todo-list
# de este modo, por cada usuario que manipule un todo-list, se tendra un proceso
# y por lo tanto, la manipulacion de las todo-list se hace de forma concurrente.
# La forma en que se crean estos procesos es a traves de un Map, que tiene la siguiente forma:
# %{ <server_name>: <PID> }, donde "server_name" es el nombre que queremos que tenga
# el PID de un determinado todo-list, por ejemplo, para el usuario "leonardo" podriamos
# mapear el proceso que se encarga de manipular su todo-list de la siguiente forma
# %{"leonardo_todo" => <PID>}, en este caso, este seria el estado del proceso de este modulo,
# entonces al querer acceder al todo-list de leonardo, obtenemos su PID a traves de la key "leonardo_todo"
# Para esto tendriamos que llamar al metodo de interfaz server_process(<cache_pid>, "leonardo_todo")

defmodule Todo.Cache do

  # @impl GenServer
  # def init(_) do
  #   {:ok, %{}}
  # end

  # @impl GenServer
  # def handle_call({:server_process, todo_name}, _, todo_servers) do
  #   case Map.fetch(todo_servers, todo_name) do

  #     {:ok, todo_server} ->
  #       {:reply, todo_server, todo_servers}

  #     #En caso de que no exista, generar el proceso del todo_list solicitado,
  #     # y agregarlo al mapa de todo_servers que es el estado
  #     :error ->
  #       {:ok, new_todo_server} = Todo.Server.start_link(todo_name)

  #       new_state = Map.put(todo_servers, todo_name, new_todo_server)

  #       {:reply, new_todo_server, new_state}
  #   end
  # end

  # INTERFACES FUNCTIONS
  def start_link() do
    IO.puts("Starting todo-cache.")

    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  defp start_child(todo_list_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Todo.Server, todo_list_name}
    )
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def server_process(todo_list_name) do
    case start_child(todo_list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
