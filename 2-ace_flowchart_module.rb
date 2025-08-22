#!/usr/bin/env ruby
# ACE FLOWCHART v4.2.0
# ====================================
# File 2: ACE Flowchart JSON Processor
# This module processes the programmatic representation of ACE's processing architecture
# Author: ACE Development Team
# Version: 4.2.0
# Status: Production Ready

require 'json'

class FlowNode
  attr_accessor :node_id, :name, :description, :parent, :children, :node_class
  
  def initialize(node_id:, name:, description:, parent:, children:, node_class:)
    @node_id = node_id
    @name = name
    @description = description
    @parent = parent
    @children = children
    @node_class = node_class
  end
  
  def to_s
    "FlowNode(#{@node_id}, #{@name}, class=#{@node_class})"
  end
end

class ACEFlowchart
  def initialize(json_data)
    @nodes = {}
    json_data.fetch("nodes", []).each do |node|
      node_id = node.fetch("NodeID")
      @nodes[node_id] = FlowNode.new(
        node_id: node_id,
        name: node.fetch("NodeName"),
        description: node.fetch("Description", []),
        parent: node.fetch("ParentNode", nil),
        children: node.fetch("ChildNodes", []),
        node_class: node.fetch("Class")
      )
    end
  end
  
  def get_node(node_id)
    @nodes[node_id]
  end
  
  def display_flow
    @nodes.each do |node_id, node|
      puts "#{node_id}: #{node.name} -> Children: #{node.children}"
    end
  end
  
  def find_path_to_root(node_id)
    path = []
    current = get_node(node_id)
    while current
      path.unshift(current.name)
      current = current.parent ? get_node(current.parent) : nil
    end
    path
  end
end

# Example usage
if __FILE__ == $0
  data = JSON.parse(File.read("2-ace_flowchart.json"))
  ace_flow = ACEFlowchart.new(data)
  ace_flow.display_flow
  puts "\nPath to root for 'C1R1': #{ace_flow.find_path_to_root("C1R1").join(" -> ")}"
end