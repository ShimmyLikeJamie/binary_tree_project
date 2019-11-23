class Node
  include Comparable
  attr_accessor :value, :left, :right
  def initialize(value=nil, left=nil, right=nil)
    @value = value
    @left = left
    @right = right
  end

  def leaf?
    @left == nil && @right == nil
  end

  def one_child?
    @left == nil || @right == nil && !(@left == nil && @right == nil)
  end
end