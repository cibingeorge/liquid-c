# encoding: utf-8
require 'test_helper'

class TokenizerTest < Minitest::Test
  def test_tokenize_strings
    assert_equal [' '], tokenize(' ')
    assert_equal ['hello world'], tokenize('hello world')
  end

  def test_tokenize_variables
    assert_equal ['{{funk}}'], tokenize('{{funk}}')
    assert_equal [' ', '{{funk}}', ' '], tokenize(' {{funk}} ')
    assert_equal [' ', '{{funk}}', ' ', '{{so}}', ' ', '{{brother}}', ' '], tokenize(' {{funk}} {{so}} {{brother}} ')
    assert_equal [' ', '{{  funk  }}', ' '], tokenize(' {{  funk  }} ')

    # Doesn't strip whitespace
    assert_equal [' ', '  funk  ', ' '], tokenize(' {{  funk  }} ', trimmed: true)
  end

  def test_tokenize_blocks
    assert_equal ['{%comment%}'], tokenize('{%comment%}')
    assert_equal [' ', '{%comment%}', ' '], tokenize(' {%comment%} ')

    assert_equal [' ', '{%comment%}', ' ', '{%endcomment%}', ' '], tokenize(' {%comment%} {%endcomment%} ')
    assert_equal ['  ', '{% comment %}', ' ', '{% endcomment %}', ' '], tokenize("  {% comment %} {% endcomment %} ")

    # Doesn't strip whitespace
    assert_equal [' ', '  comment  ', ' '], tokenize(' {%  comment  %} ', trimmed: true)
  end

  def test_tokenize_for_liquid_tag
    source = "\nfunk\n\n  so | brother   \n"

    assert_equal ["\nfunk\n\n  ", "so | brother   \n"], tokenize(source, for_liquid_tag: true)

    # Strips whitespace
    assert_equal ["funk", "so | brother"], tokenize(source, for_liquid_tag: true, trimmed: true)
  end

  def test_utf8_encoded_template
    source = 'auswählen'
    assert_equal Encoding::UTF_8, source.encoding
    output = tokenize(source)
    assert_equal [Encoding::UTF_8], output.map(&:encoding)
    assert_equal [source], output
  end

  def test_non_utf8_encoded_template
    source = String.new('ascii text', encoding: Encoding::BINARY)
    exc = assert_raises(Encoding::CompatibilityError) do
      Liquid::C::Tokenizer.new(source, 1, false)
    end
    assert_equal("non-UTF8 encoded source (ASCII-8BIT) not supported", exc.message)
  end

  private

  def tokenize(source, for_liquid_tag: false, trimmed: false)
    tokenizer = Liquid::C::Tokenizer.new(source, 1, for_liquid_tag)
    tokens = []
    while t = (trimmed ? tokenizer.send(:shift_trimmed) : tokenizer.shift)
      tokens << t
    end
    tokens
  end
end
