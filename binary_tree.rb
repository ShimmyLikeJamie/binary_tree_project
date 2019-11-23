require './node.rb'
require 'pry'

MAX = 4611686018427387903
class Tree
  attr_reader :root
  def initialize(arr)
    @root = build_tree(arr)
  end

  def insert value
    current_node = @root
    loop do
      if value == current_node.value
        return "Duplicate value"
      elsif value < current_node.value
        if current_node.left.nil?
          current_node.left = Node.new(value)
          break
        else
          current_node = current_node.left
        end
      else
        if current_node.right.nil?
          current_node.right = Node.new(value)
          break
        else
          current_node = current_node.right
        end
      end
    end
    current_node
  end

  def delete value
    previous_node = @root
    current_node = @root
    lesser = false
    loop do
      if value == current_node.value
        if current_node == @root
          @root = nil
          break
        elsif current_node.leaf?
          if lesser
            previous_node.left = nil
          else
            previous_node.right = nil
          end
          break
        elsif current_node.one_child?
          if current_node.left == nil
            if lesser
              previous_node.left = current_node.right
            else
              previous_node.right = current_node.right
            end
          else
            if lesser
              previous_node.left = current_node.left
            else
              previous_node.right = current_node.left
            end
          end
          break
        else
          last_node_value, result = find_successor(@root, value)
          if last_node_value - value > result - value && last_node_value - value > 0
            result = last_node_value
          end
          successor = replace_with_successor(@root, result, previous_node, lesser)
          successor.left = current_node.left
          return
        end
      elsif value < current_node.value
        if current_node.left.nil?
          return "Value does not exist."
        else
          lesser = true
          previous_node = current_node
          current_node = current_node.left
        end
      else
        if current_node.right.nil?
          return "Value does not exist."
        else
          lesser = false
          previous_node = current_node
          current_node = current_node.right
        end
      end
    end
  end

  def level_order
  end

  def find value
    result = find_recursion(value)
    if result.nil?
      return "Value not found"
    else
      result
    end
  end

  def find_recursion value, node=@root, result=nil
    if !node.left.nil?
      result = find_recursion value, node.left
    end
    if !node.right.nil?
      result = find_recursion value, node.right
    end
    if value == node.value
      result = node
    end
    return result
  end
end

def find_successor node, value=nil, result=MAX
  if node.left.nil? && node.right.nil? #Base case
    return node.value, result
  else
    if !node.left.nil?
      node_value, result = find_successor(node.left, value)
      difference = node_value - value
      if difference == 0
      elsif difference < result - value && difference > 0
        result = node_value
      end
    end
    if !node.right.nil?
      node_value, result = find_successor(node.right, value)
      difference = node_value - value
      if difference == 0
      elsif difference < result - value && difference > 0
        result = node_value
      end
    end
    return node.value, result
  end
end

def replace_with_successor root, value, parent_of_node_to_replace, lesser
  previous_node = root
  current_node = root
  loop do
    if current_node.value == value
      if lesser
        parent_of_node_to_replace.left = current_node
        return current_node
      else
        parent_of_node_to_replace.right = current_node
        return current_node
      end
    elsif value < current_node.value
      previous_node = current_node
      current_node = current_node.left
    else
      previous_node = current_node
      current_node = current_node.right
    end
  end
end

def build_tree(arr)
  root = nil
  arr.each do |data|
    if root.nil?
      root = Node.new(data)
    else
      current_node = root
      loop do
        if data < current_node.value
          if current_node.left.nil?
            current_node.left = Node.new(data)
            break
          else
            current_node = current_node.left
          end
        elsif data == current_node.value
          next
        else
          if current_node.right.nil?
            current_node.right = Node.new(data)
            break
          else
            current_node = current_node.right
          end
        end
      end
    end
  end
  root
end

example_array = [3, 5, 4, 70, 100, 2, 0, 1]
example_tree = Tree.new(example_array)
binding.pry
puts "#{example_tree.find(5)}"