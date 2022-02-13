defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image { hex: hex }
  end

  # pick_color receives an %Identicon.Image{}
  # We can pattern match/destructure it directly in the function definition like so:
  def pick_color(%Identicon.Image { hex: [r, g, b | _tail] } = image) do
    %Identicon.Image { image | color: { r, g, b} }
  end

  def build_grid(%Identicon.Image { hex: hex } = image) do
    grid =
      hex
      |> Enum.chunk(3)
      # &method_name/num_arguments to pass a reference to a function
      |> Enum.map(&mirrow_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image { image | grid: grid }
  end

  def mirrow_row(row) do
    # [145, 46, 200]
    [first, second | _tail] = row

    # ++ is an operator for appending two lists
    #[1465, 46, 200, 46, 145]
    row ++ [second, first]
  end

  def filter_odd_squares(%Identicon.Image { grid: grid } = image) do
    grid = Enum.filter grid, fn({rgb, _index}) ->
      rem(rgb, 2) == 0
    end

    %Identicon.Image { image | grid: grid }
  end

  def build_pixel_map(%Identicon.Image { grid: grid } = image) do
    pixel_map = Enum.map grid, fn({_rgb, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = { horizontal, vertical }
      bottom_right = { horizontal + 50, vertical + 50 }

      {top_left, bottom_right}
    end

    %Identicon.Image { image | pixel_map: pixel_map }
  end

  # We do not need to provide an underscore prepended variable to represent
  # pattern matched items we don't care about when pattern matching in a function declaration
  def draw_image(%Identicon.Image { color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({ start, stop }) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end
end
