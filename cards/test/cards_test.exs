defmodule CardsTest do
  use ExUnit.Case
  doctest Cards

  test "create_deck makes 20 cards" do
    deck_length = length(Cards.create_deck)
    assert deck_length == 20
  end

  test "shuffling a deck randomizes it" do
    deck = Cards.create_deck
    # a bit of a flimsy test -- there is a chance, albeit a slim one,
    # that shuffle returns a deck in exactly the same order as the first
    assert deck != Cards.shuffle(deck)
    # alternative assert syntax
    # refute deck == Cards.shuffle(deck)
  end
end
