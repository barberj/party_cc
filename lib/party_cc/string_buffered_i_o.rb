class StringBufferedIO < StringIO
  alias_method :old_readline, :readline

  def readline
    old_readline.strip
  end

  def readuntil *args
    old_readline
  end
end
