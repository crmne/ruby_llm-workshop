#!/usr/bin/env ruby
require_relative "../config/environment"
require "async"

class SecurityReviewAgent < RubyLLM::Agent
  instructions "Given code, review it for security issues."
end

class PerformanceReviewAgent < RubyLLM::Agent
  instructions "Given code, review it for performance issues."
end

class StyleReviewAgent < RubyLLM::Agent
  instructions "Given code, review style against Ruby conventions."
end

class ReviewSynthesizerAgent < RubyLLM::Agent
  instructions "Given multiple code review reports, summarize prioritized findings."
end

code = ARGV.join(" ").presence || "def calculate(x); x * 2; end"
puts "Reviewing: #{code}\n\n"

result = Async do |task|
  security = task.async do
    puts "🔒 Security review starting..."
    result = SecurityReviewAgent.new.ask(code).content
    puts "🔒 Security review done."
    result
  end

  performance = task.async do
    puts "⚡ Performance review starting..."
    result = PerformanceReviewAgent.new.ask(code).content
    puts "⚡ Performance review done."
    result
  end

  style = task.async do
    puts "🎨 Style review starting..."
    result = StyleReviewAgent.new.ask(code).content
    puts "🎨 Style review done."
    result
  end

  security = security.wait
  performance = performance.wait
  style = style.wait
  puts "📝 Synthesizing..."
  ReviewSynthesizerAgent.new.ask(
    "security: #{security}\n\n" \
    "performance: #{performance}\n\n" \
    "style: #{style}"
  ).content
end.wait

puts "\n#{result}"
