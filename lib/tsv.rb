class TSV
  include Enumerable

  attr_reader :filepath, :col_sep, :headers, :file_handle

  # Optionally pass in a different :col_sep as an optional hash param. The
  # default :col_sep is tab.
  def initialize(filepath, col_sep: "\t")
    @filepath = filepath
    @col_sep = col_sep
    @file_handle = File.open(filepath)
    @headers = @file_handle.gets.chomp!.split(col_sep, -1).map(&:downcase).map(&:to_sym)
  end

  # Yield a row hash to the block with downcased, symbolized keys.
  def each(&block)
    file_handle.each do |line|
      yield headers.zip(line.chomp!.split(col_sep, -1)).to_h
    end
  end

  # Faster implementation of #count. Instead of parsing the whole file with
  # Ruby, shell out to `wc -l` to get the line count less the header row.
  def count
    `wc -l < #{filepath}`.to_i - 1
  end

  # Rewind the file handle to line 2 (skipping the header row).
  def rewind
    file_handle.rewind
    file_handle.gets # skip past header
    nil
  end
end
