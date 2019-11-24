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
    queue = [@root]
    values = []
    until queue.empty?
      queue.push(queue[0].left) unless queue[0].left.nil?
      queue.push(queue[0].right) unless queue[0].right.nil?
      if block_given?
        yield(queue[0].value)
      end
      values.push(queue[0].value)
      queue.shift
    end
    values
  end

  def inorder node=@root, values=[]
    values = inorder(node.left, values) unless node.left.nil?
    values.push(node.value)
    values = inorder(node.right, values) unless node.right.nil?
    values
  end
  def preorder node=@root, values=[]
    values.push(node.value)
    values = preorder(node.left, values) unless node.left.nil?
    values = preorder(node.right, values) unless node.right.nil?
    values
  end
  def postorder node=@root, values=[]
    values = postorder(node.left, values) unless node.left.nil?
    values = postorder(node.right, values) unless node.right.nil?
    values.push(node.value)
    values
  end

  def depth_algorithm rebalance = false, node=@root, parent=@root, levels = 0, balanced = true
    left_tree_depth, balanced = depth_algorithm(rebalance, node.left, node, levels + 1, balanced) unless node.left.nil?
    right_tree_depth, balanced = depth_algorithm(rebalance, node.right, node, levels + 1, balanced) unless node.right.nil?
    if left_tree_depth.nil? && right_tree_depth.nil?
    elsif right_tree_depth.nil? && !left_tree_depth.nil?
      current_level = levels
      levels = left_tree_depth
      if left_tree_depth - current_level > 1 && rebalance
        rebalance_left(node, parent)
        levels -= 1
      end
    elsif left_tree_depth.nil? && !right_tree_depth.nil?
      current_level = levels
      levels = right_tree_depth
      if right_tree_depth - current_level > 1 && rebalance
        rebalance_right(node, parent)
        levels -= 1
      end
    elsif left_tree_depth > right_tree_depth
      levels = left_tree_depth
      if left_tree_depth - right_tree_depth > 1
        balanced = false
        if rebalance
          rebalance_left(node, parent)
          levels -= 1
        end
      end
    else
      levels = right_tree_depth
      if right_tree_depth - left_tree_depth > 1
        balanced = false
        if rebalance
          rebalance_right(node, parent)
          levels -= 1
        end
      end
    end
    return levels, balanced
  end

  def depth node
    levels, balanced = depth_algorithm(false, node)
    levels
  end

  def balanced?
    depth, balanced = depth_algorithm(false)
    balanced ? true : false
  end

  def rebalance!
    depth_algorithm(true)
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

def rebalance_left node, parent
  node.left.right = node
  if parent.left == node
    parent.left = node.left
  else
    parent.right = node.left
  end
  node.left = nil
end
def rebalance_right node, parent
  node.right.left = node
  if parent.left == node
    parent.left = node.right
  else
    parent.right = node.right
  end
  node.right = nil
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
          break
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

print "Creating new array... "
example_array = Array.new(15) { rand(1..100)}
puts "Done"
print "Creating new tree... "
example_tree = Tree.new(example_array)
puts "Done"
puts "Is tree balanced?: #{example_tree.balanced?}"
puts "Inorder: #{example_tree.inorder}"
puts "Preorder: #{example_tree.preorder}"
puts "Postorder: #{example_tree.postorder}"
print "Unbalancing... "
example_array.push(100, 200, 300)
puts "Done"
puts "Is tree balanced?: #{example_tree.balanced?}"
print "Rebalancing... "
example_tree.rebalance!
puts "Done"
puts "Is tree balanced?: #{example_tree.balanced?}"
puts "Printing all elements..."
puts "Inorder: #{example_tree.inorder}"
puts "Preorder: #{example_tree.preorder}"
puts "Postorder: #{example_tree.postorder}"
puts "Level order: #{example_tree.level_order}"