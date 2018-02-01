defmodule Servy.BearController do

  alias Servy.Wildthings
  alias Servy.Bear

  import Servy.View, only: [render: 3]

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{ conv | resp_body: "Created a #{type} bear named #{name}!", status: 201}
  end

  def delete(conv, _params) do
    %{ conv | resp_body: "Bears must never be deleted!", status: 403}
  end
end