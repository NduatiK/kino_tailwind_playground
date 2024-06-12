defmodule KinoTailwindPlayground do
  use Kino.JS, assets_path: "lib/assets/playground"
  use Kino.JS.Live
  use Kino.SmartCell, name: "Tailwind Playground"

  require Logger

  @impl true
  def init(attrs, ctx) do
    {:ok,
     assign(ctx,
       assigns: nil,
       html: attrs["html"] || "",
       default_width: attrs["default_width"] || nil,
       default_height: attrs["default_height"] || nil
     ), editor: [attribute: "html", language: "html", placement: :top]}
  end

  @impl true
  def scan_binding(pid, binding, _env) do
    assigns =
      binding
      |> Enum.flat_map(fn
        {:assigns, val} ->
          [val]

        _ ->
          []
      end)
      |> Kernel.++([nil])
      |> hd

    send(pid, {:set_assigns, assigns})
  end

  @impl true
  def handle_connect(ctx) do
    {:ok,
     %{
       html: ctx.assigns.html,
       assigns: ctx.assigns.assigns,
       default_width: ctx.assigns[:default_width],
       default_height: ctx.assigns[:default_height]
     }, ctx}
  end

  @impl true
  def handle_event("initial-render", %{}, ctx) do
    Process.send_after(self(), {:display_html_self, ctx.assigns.html}, 400)
    {:noreply, ctx}
  end

  @impl true
  def handle_event("resized", %{"height" => height}, ctx) do
    {:noreply,
     ctx
     |> assign(default_height: height)
     |> broadcast_changes("resized", %{"height" => height})}
  end

  @impl true
  def handle_event("resized", %{"width" => width}, ctx) do
    {:noreply,
     ctx
     |> assign(default_width: width)
     |> broadcast_changes("resized", %{"width" => width})}
  end

  @impl true
  def to_attrs(ctx) do
    %{
      "html" => ctx.assigns.html,
      "default_height" => ctx.assigns[:default_height],
      "default_width" => ctx.assigns[:default_width]
    }
  end

  @impl true
  def to_source(attrs) do
    # we can't encode ctx in attrs so we send ourselves a message in order to display the html.
    send(self(), {:display_html_self, attrs["html"]})

    """
    html = \"\"\"
    #{attrs["html"]}
    \"\"\"

    Kino.nothing()
    """
  end

  @impl true
  def handle_info({:display_html_self, html}, ctx) do
    {:noreply,
     ctx
     |> assign(html: html)}
  end

  @impl true
  def handle_info({:display_html, html}, ctx) do
    {:noreply,
     ctx
     |> assign(html: html)
     |> broadcast_html()}
  end

  @impl true
  def handle_info({:set_assigns, assigns}, ctx) do
    {:noreply,
     ctx
     |> assign(assigns: assigns)
     |> broadcast_html()}
  end

  def broadcast_changes(ctx, event, data) do
    # broadcast_event(ctx, event, data)
    ctx
  end

  def broadcast_html(ctx) do
    html =
      try do
        {result, _bindings} =
          ctx.assigns.html
          |> EEx.compile_string()
          |> Code.eval_quoted(Enum.to_list(ctx.assigns.assigns))

        result
      rescue
        e ->
          IO.inspect(e)
          IO.inspect("Please provide an assigns variable")
          ctx.assigns.html
      end

    broadcast_event(ctx, "display-html", %{"html" => html})

    ctx
  end
end
