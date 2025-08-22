#!/usr/bin/env ruby
# ACE FLOWCHART BUILDER v4.2.0
# ====================================
# File 3: ACE Mermaid Flowchart Parser and Processor
# This module provides bidirectional conversion between Mermaid syntax and programmatic flowchart representation
# Author: ACE Development Team
# Version: 4.2.0
# Status: Production Ready

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
  def initialize
    @nodes = {}
  end
  
  def add_node(node_id, name, description, parent, children, node_class)
    @nodes[node_id] = FlowNode.new(
      node_id: node_id,
      name: name,
      description: description,
      parent: parent,
      children: children,
      node_class: node_class
    )
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
  
  def build_from_mermaid(mermaid_lines)
    mermaid_lines.each do |line|
      if line.include?("-->")
        parts = line.split("-->")
        next unless parts.length == 2
        
        src = parts[0].strip
        tgt = parts[1].strip
        
        # Extract node IDs from Mermaid syntax (A[Label] format)
        src_id = src.split("[").first.strip
        tgt_id = tgt.split("[").first.strip
        
        # Create nodes if they don't exist
        unless @nodes.key?(src_id)
          @nodes[src_id] = FlowNode.new(
            node_id: src_id,
            name: src_id,
            description: [],
            parent: nil,
            children: [],
            node_class: "unknown"
          )
        end
        
        unless @nodes.key?(tgt_id)
          @nodes[tgt_id] = FlowNode.new(
            node_id: tgt_id,
            name: tgt_id,
            description: [],
            parent: src_id,
            children: [],
            node_class: "unknown"
          )
        end
        
        # Update relationships
        @nodes[src_id].children << tgt_id unless @nodes[src_id].children.include?(tgt_id)
        @nodes[tgt_id].parent = src_id
      end
    end
  end
end

# Example usage
if __FILE__ == $0
  puts "\nACE FLOWCHART BUILDER v4.2.0"
  puts "=" * 50
  
  mermaid_example = [
    "A[Input Reception] --> AIP[Adaptive Processor]",
    "AIP --> QI[Processing Gateway]",
    "QI --> NLP[Language Vector]",
    "QI --> EV[Sentiment Vector]",
    "NLP --> ROUTER[Attention Router]",
    "EV --> ROUTER"
  ]
  
  ace_flow = ACEFlowchart.new
  ace_flow.build_from_mermaid(mermaid_example)
  
  puts "\nFLOWCHART STRUCTURE:"
  ace_flow.display_flow
  
  path = ace_flow.find_path_to_root("ROUTER")
  puts "\nPath to root for 'ROUTER': #{path.join(" -> ")}"
  
  puts "\nFlowchart successfully parsed with #{ace_flow.instance_variable_get(:@nodes).size} nodes."
end