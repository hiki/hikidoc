# Copyright (c) 2002-2005 Minero Aoki
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of the HikiDoc nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class LineInput
  def initialize(f)
    @input = f
    @buf = []
    @lineno = 0
    @eof_p = false
  end

  def inspect
    "\#<#{self.class} file=#{@input.inspect} line=#{lineno()}>"
  end

  def eof?
    @eof_p
  end

  def lineno
    @lineno
  end

  def gets
    unless @buf.empty?
      @lineno += 1
      return @buf.pop
    end
    return nil if @eof_p   # to avoid ARGF blocking.
    line = @input.gets
    @eof_p = true unless line
    @lineno += 1
    line
  end

  def ungets(line)
    return unless line
    @lineno -= 1
    @buf.push line
    line
  end

  def peek
    line = gets()
    ungets line if line
    line
  end

  def next?
    peek() ? true : false
  end

  def skip_blank_lines
    n = 0
    while line = gets()
      unless line.strip.empty?
        ungets line
        return n
      end
      n += 1
    end
    n
  end

  def gets_if(re)
    line = gets()
    if not line or not (re =~ line)
      ungets line
      return nil
    end
    line
  end

  def gets_unless(re)
    line = gets()
    if not line or re =~ line
      ungets line
      return nil
    end
    line
  end

  def each
    while line = gets()
      yield line
    end
  end

  def while_match(re)
    while line = gets()
      unless re =~ line
        ungets line
        return
      end
      yield line
    end
    nil
  end

  def getlines_while(re)
    buf = []
    while_match(re) do |line|
      buf.push line
    end
    buf
  end

  alias span getlines_while   # from Haskell

  def until_match(re)
    while line = gets()
      if re =~ line
        ungets line
        return
      end
      yield line
    end
    nil
  end

  def getlines_until(re)
    buf = []
    until_match(re) do |line|
      buf.push line
    end
    buf
  end

  alias break getlines_until   # from Haskell

  def until_terminator(re)
    while line = gets()
      return if re =~ line   # discard terminal line
      yield line
    end
    nil
  end

  def getblock(term_re)
    buf = []
    until_terminator(term_re) do |line|
      buf.push line
    end
    buf
  end
end
