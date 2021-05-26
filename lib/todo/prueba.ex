defmodule Prueba do

  def run_query(query) do
    if query == 13 do
      raise("Mientas mas me lo mamas, mas me crece. salu2.")
    end
    Process.sleep(3000)
    "Query result #{query}"
  end

  def run_query_async(query) do
    Task.async(fn -> run_query(query) end)
  end

  def run_queries(quantity) when is_number(quantity) do
    Enum.map(1..quantity, &run_query_async/1)
  end

  def get_results(queries) when is_list(queries) do
    Enum.map(queries, &Task.await/1)
  end

end
