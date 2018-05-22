#******************************************************************************
# ALX - Skies of Arcadia Legends Examiner
# Copyright (C) 2018 Marcel Renner
# 
# This file is part of ALX.
# 
# ALX is free software: you can redistribute it and/or modify it under the 
# terms of the GNU General Public License as published by the Free Software 
# Foundation, either version 3 of the License, or (at your option) any later 
# version.
# 
# ALX is distributed in the hope that it will be useful, but WITHOUT ANY 
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more 
# details.
# 
# You should have received a copy of the GNU General Public License along with 
# ALX. If not, see <http://www.gnu.org/licenses/>.
#******************************************************************************

#==============================================================================
#                                 REQUIREMENTS
#==============================================================================

require('fileutils')
require_relative('binaryfile.rb')
require_relative('datarange.rb')
require_relative('entrydata.rb')
require_relative('entrytransform.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================

# Base class to handle standard entries from binary and/or CSV files.
class StdEntryData < EntryData
  
#==============================================================================
#                                  CONSTANTS
#==============================================================================

  STR_OPEN_NAME  = 'names'
  STR_OPEN_DSCR  = 'descriptions'

#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  # Constructs a StdEntryData.
  # @param _class [Entry]    Entry object
  # @param _root  [GameRoot] Game root
  def initialize(_class, _root)
    super
    @id_range   = 0x0...0x0
    @data_files = {}
    @name_files = {}
    @dscr_files = {}
    @csv_file   = ''
    @data       = Hash.new { |_h, _k| _h[_k] = create_entry(_k) }
  end

  # Creates an entry.
  # @param _id [Integer] Entry ID
  # @return [Entry] Entry object
  def create_entry(_id = -1)
    _entry    = super()
    _entry.id = _id
    _entry
  end

  # Reads all data entries from a binary file.
  # @param _filename [String] File name
  def load_data_from_bin(_filename)
    print("\n")
    puts(sprintf(STR_OPEN, _filename, STR_OPEN_READ, STR_OPEN_DATA))

    BinaryFile.open(_filename, 'rb') do |_f|
      _range = determine_range(@data_files[region], _filename)
      _size  = create_entry.size
      _f.pos = _range.begin
      
      @id_range.each do |_id|
        if _f.eof? || _f.pos < _range.begin || _f.pos + _size > _range.end
          break
        end
        if _range.exclusion.include?(_id)
          next
        end
        
        puts(sprintf(STR_READ, _id - @id_range.begin, _f.pos))
        _entry = @data[_id]
        _entry.read_from_bin(_f)
      end
    end
    
    puts(sprintf(STR_CLOSE, _filename))
  end
    
  # Reads all name entries from a binary file.
  # @param _filename [String] File name
  def load_names_from_bin(_filename)
    print("\n")
    puts(sprintf(STR_OPEN, _filename, STR_OPEN_READ, STR_OPEN_NAME))

    BinaryFile.open(_filename, 'rb') do |_f|
      _range = determine_range(@name_files[region], _filename)
      _f.pos = _range.begin
      
      @id_range.each do |_id|
        if _f.eof? || _f.pos < _range.begin || _f.pos >= _range.end
          break
        end
        if _range.exclusion.include?(_id)
          next
        end

       _entry = @data[_id]
    
        case determine_lang(_filename)
        when 'DE'
          _pos  = _entry.find_member(CsvHdr::NAME_DE_POS )
          _size = _entry.find_member(CsvHdr::NAME_DE_SIZE)
          _str  = _entry.find_member(CsvHdr::NAME_DE_STR )
        when 'ES'
          _pos  = _entry.find_member(CsvHdr::NAME_ES_POS )
          _size = _entry.find_member(CsvHdr::NAME_ES_SIZE)
          _str  = _entry.find_member(CsvHdr::NAME_ES_STR )
        when 'FR'
          _pos  = _entry.find_member(CsvHdr::NAME_FR_POS )
          _size = _entry.find_member(CsvHdr::NAME_FR_SIZE)
          _str  = _entry.find_member(CsvHdr::NAME_FR_STR )
        when 'GB'
          _pos  = _entry.find_member(CsvHdr::NAME_GB_POS )
          _size = _entry.find_member(CsvHdr::NAME_GB_SIZE)
          _str  = _entry.find_member(CsvHdr::NAME_GB_STR )
        end
        
        puts(sprintf(STR_READ, _id - @id_range.begin, _f.pos))
        _pos.value  = _f.pos
        _str.value  = _f.read_str(0xff, 0x1, 'ISO8859-1')
        _size.value = _f.pos - _pos.value
      end
    end

    puts(sprintf(STR_CLOSE, _filename))
  end
  
  # Reads all description entries from a binary file.
  # @param _filename [String] File name
  def load_dscr_from_bin(_filename)
    print("\n")
    puts(sprintf(STR_OPEN, _filename, STR_OPEN_READ, STR_OPEN_DSCR))

    BinaryFile.open(_filename, 'rb') do |_f|
      _range = determine_range(@dscr_files[region], _filename)
      _f.pos = _range.begin
      
      @id_range.each do |_id|
        if _f.eof? || _f.pos < _range.begin || _f.pos >= _range.end
          break 
        end
        if _range.exclusion.include?(_id)
          next
        end

        _entry = @data[_id]
    
        case region
        when 'E'
          _pos  = _entry.find_member(CsvHdr::DSCR_US_POS )
          _size = _entry.find_member(CsvHdr::DSCR_US_SIZE)
          _str  = _entry.find_member(CsvHdr::DSCR_US_STR )
        when 'J'
          _pos  = _entry.find_member(CsvHdr::DSCR_JP_POS )
          _size = _entry.find_member(CsvHdr::DSCR_JP_SIZE)
          _str  = _entry.find_member(CsvHdr::DSCR_JP_STR )
        when 'P'
          case determine_lang(_filename)
          when 'DE'
            _pos  = _entry.find_member(CsvHdr::DSCR_DE_POS )
            _size = _entry.find_member(CsvHdr::DSCR_DE_SIZE)
            _str  = _entry.find_member(CsvHdr::DSCR_DE_STR )
          when 'ES'
            _pos  = _entry.find_member(CsvHdr::DSCR_ES_POS )
            _size = _entry.find_member(CsvHdr::DSCR_ES_SIZE)
            _str  = _entry.find_member(CsvHdr::DSCR_ES_STR )
          when 'FR'
            _pos  = _entry.find_member(CsvHdr::DSCR_FR_POS )
            _size = _entry.find_member(CsvHdr::DSCR_FR_SIZE)
            _str  = _entry.find_member(CsvHdr::DSCR_FR_STR )
          when 'GB'
            _pos  = _entry.find_member(CsvHdr::DSCR_GB_POS )
            _size = _entry.find_member(CsvHdr::DSCR_GB_SIZE)
            _str  = _entry.find_member(CsvHdr::DSCR_GB_STR )
          end
        end
        
        puts(sprintf(STR_READ, _id - @id_range.begin, _f.pos))
        _pos.value  = _f.pos
        if region != 'P'
          _str.value  = _f.read_str(0xff, 0x4)
        else
          _str.value  = _f.read_str(0xff, 0x1, 'ISO8859-1')
        end
        _size.value = _f.pos - _pos.value
      end
    end

    puts(sprintf(STR_CLOSE, _filename))
  end

  # Reads all entries from binary files.
  def load_all_from_bin
    _ranges = @data_files[region]
    if _ranges
      unless _ranges.is_a?(Array)
        _ranges = [_ranges]
      end
      _ranges.each do |_range|
        load_data_from_bin(File.join(root.path, _range.name))
      end
    end
  
    _ranges = @name_files[region]
    if _ranges
      unless _ranges.is_a?(Array)
        _ranges = [_ranges]
      end
      _ranges.each do |_range|
        load_names_from_bin(File.join(root.path, _range.name))
      end
    end
  
    _ranges = @dscr_files[region]
    if _ranges
      unless _ranges.is_a?(Array)
        _ranges = [_ranges]
      end
      _ranges.each do |_range|
        load_dscr_from_bin(File.join(root.path, _range.name))
      end
    end
  end
    
  # Writes all data entries to a binary file.
  # @param _filename [String] File name
  def save_data_to_bin(_filename)
    if @data.empty?
      return
    end
    
    print("\n")
    puts(sprintf(STR_OPEN, _filename, STR_OPEN_WRITE, STR_OPEN_DATA))

    FileUtils.mkdir_p(File.dirname(_filename))
    BinaryFile.open(_filename, 'r+b') do |_f|
      _range = determine_range(@data_files[region], _filename)
      _size  = create_entry.size
      
      @data.each do |_id, _entry|
        if _id < @id_range.begin && _id >= @id_range.end
          next
        end
        if _range.exclusion.include?(_id)
          next
        end
        
        _f.pos = _range.begin + (_id - @id_range.begin) * _size
  
        if _f.eof? || _f.pos < _range.begin || _f.pos + _size > _range.end
          next
        end
        
        puts(sprintf(STR_WRITE, _id - @id_range.begin, _f.pos))
        _entry.write_to_bin(_f)
      end
    end

    puts(sprintf(STR_CLOSE, _filename))
  end
    
  # Writes all name entries to a binary file.
  # @param _filename [String] File name
  def save_names_to_bin(_filename)
    if @data.empty?
      return
    end
    
    print("\n")
    puts(sprintf(STR_OPEN, _filename, STR_OPEN_WRITE, STR_OPEN_NAME))

    FileUtils.mkdir_p(File.dirname(_filename))
    BinaryFile.open(_filename, 'r+b') do |_f|
      _range = determine_range(@name_files[region], _filename)
      
      @data.each do |_id, _entry|
        if _id < @id_range.begin && _id >= @id_range.end
          next
        end
        if _range.exclusion.include?(_id)
          next
        end
        
        case determine_lang(_filename)
        when 'DE'
          _pos  = _entry.find_member(CsvHdr::NAME_DE_POS ).value
          _size = _entry.find_member(CsvHdr::NAME_DE_SIZE).value
          _str  = _entry.find_member(CsvHdr::NAME_DE_STR ).value
        when 'ES'
          _pos  = _entry.find_member(CsvHdr::NAME_ES_POS ).value
          _size = _entry.find_member(CsvHdr::NAME_ES_SIZE).value
          _str  = _entry.find_member(CsvHdr::NAME_ES_STR ).value
        when 'FR'
          _pos  = _entry.find_member(CsvHdr::NAME_FR_POS ).value
          _size = _entry.find_member(CsvHdr::NAME_FR_SIZE).value
          _str  = _entry.find_member(CsvHdr::NAME_FR_STR ).value
        when 'GB'
          _pos  = _entry.find_member(CsvHdr::NAME_GB_POS ).value
          _size = _entry.find_member(CsvHdr::NAME_GB_SIZE).value
          _str  = _entry.find_member(CsvHdr::NAME_GB_STR ).value
        else
          _pos  = 0
          _size = 0
        end

        if _pos <= 0 || _size <= 0
          next
        end
        
        _f.pos = _pos

        if _f.eof? || _f.pos < _range.begin || _f.pos + _size > _range.end
          next
        end
        
        puts(sprintf(STR_WRITE, _id - @id_range.begin, _pos))
        _f.write_str(_str, _size, 0x1, 'ISO8859-1')
      end
    end

    puts(sprintf(STR_CLOSE, _filename))
  end
  
  # Writes all description entries to a binary file.
  # @param _filename [String] File name
  def save_dscr_to_bin(_filename)
    if @data.empty?
      return
    end
    
    print("\n")
    puts(sprintf(STR_OPEN, _filename, STR_OPEN_WRITE, STR_OPEN_DSCR))

    FileUtils.mkdir_p(File.dirname(_filename))
    BinaryFile.open(_filename, 'r+b') do |_f|
      _range = determine_range(@dscr_files[region], _filename) 

      @data.each do |_id, _entry|
        if _id < @id_range.begin && _id >= @id_range.end
          next
        end
        if _range.exclusion.include?(_id)
          next
        end

        case region
        when 'E'
          _pos  = _entry.find_member(CsvHdr::DSCR_US_POS ).value
          _size = _entry.find_member(CsvHdr::DSCR_US_SIZE).value
          _str  = _entry.find_member(CsvHdr::DSCR_US_STR ).value
        when 'J'
          _pos  = _entry.find_member(CsvHdr::DSCR_JP_POS ).value
          _size = _entry.find_member(CsvHdr::DSCR_JP_SIZE).value
          _str  = _entry.find_member(CsvHdr::DSCR_JP_STR ).value
        when 'P'
          case determine_lang(_filename)
          when 'DE'
            _pos  = _entry.find_member(CsvHdr::DSCR_DE_POS ).value
            _size = _entry.find_member(CsvHdr::DSCR_DE_SIZE).value
            _str  = _entry.find_member(CsvHdr::DSCR_DE_STR ).value
          when 'ES'
            _pos  = _entry.find_member(CsvHdr::DSCR_ES_POS ).value
            _size = _entry.find_member(CsvHdr::DSCR_ES_SIZE).value
            _str  = _entry.find_member(CsvHdr::DSCR_ES_STR ).value
          when 'FR'
            _pos  = _entry.find_member(CsvHdr::DSCR_FR_POS ).value
            _size = _entry.find_member(CsvHdr::DSCR_FR_SIZE).value
            _str  = _entry.find_member(CsvHdr::DSCR_FR_STR ).value
          when 'GB'
            _pos  = _entry.find_member(CsvHdr::DSCR_GB_POS ).value
            _size = _entry.find_member(CsvHdr::DSCR_GB_SIZE).value
            _str  = _entry.find_member(CsvHdr::DSCR_GB_STR ).value
          else
            _pos  = 0
            _size = 0
          end
        end
        
        if _pos <= 0 || _size <= 0
          next
        end
        
        _f.pos = _pos

        if _f.eof? || _f.pos < _range.begin || _f.pos + _size > _range.end
          next
        end
        
        puts(sprintf(STR_WRITE, _id - @id_range.begin, _pos))
        if region != 'P'
          _f.write_str(_str, _size, 0x4)
        else
          _f.write_str(_str, _size, 0x1, 'ISO8859-1')
        end
      end
    end

    puts(sprintf(STR_CLOSE, _filename))
  end
    
  # Writes all entries to binary files.
  def save_all_to_bin
    _ranges = @data_files[region]
    if _ranges
      unless _ranges.is_a?(Array)
        _ranges = [_ranges]
      end
      _ranges.each do |_range|
        save_data_to_bin(File.join(root.path, _range.name))
      end
    end
  
    _ranges = @name_files[region]
    if _ranges
      unless _ranges.is_a?(Array)
        _ranges = [_ranges]
      end
      _ranges.each do |_range|
        save_names_to_bin(File.join(root.path, _range.name))
      end
    end
  
    _ranges = @dscr_files[region]
    if _ranges
      unless _ranges.is_a?(Array)
        _ranges = [_ranges]
      end
      _ranges.each do |_range|
        save_dscr_to_bin(File.join(root.path, _range.name))
      end
    end
  end

  # Reads all data entries from a a CSV file.
  # @param _filename [String] File name
  def load_entries_from_csv(_filename)
    print("\n")
    puts(sprintf(STR_OPEN, _filename, STR_OPEN_READ, STR_OPEN_DATA))

    CSV.open(_filename, headers: true) do |_f|
      while !_f.eof?
        puts(sprintf(STR_READ, [0, _f.lineno - 1].max, _f.pos))
        _entry = create_entry
        _entry.read_from_csv(_f)
        @data[_entry.id] = _entry
      end
    end

    puts(sprintf(STR_CLOSE, _filename))
  end

  # Reads all entries from CSV files.
  def load_all_from_csv
    load_entries_from_csv(File.join(root.path, @csv_file))
  end

  # Writes all data entries to a CSV file.
  # @param _filename [String] File name
  def save_entries_to_csv(_filename)
    if @data.empty?
      return
    end
    
    print("\n")
    puts(sprintf(STR_OPEN, _filename, STR_OPEN_WRITE, STR_OPEN_DATA))

    _header = create_entry.header
    
    FileUtils.mkdir_p(File.dirname(_filename))
    CSV.open(_filename, 'w', headers: _header, write_headers: true) do |_f|
      @data.each do |_id, _entry|
        puts(sprintf(STR_WRITE, [0, _f.lineno - 1].max, _f.pos))
        _entry.write_to_csv(_f)
      end
    end
    
    puts(sprintf(STR_CLOSE, _filename))
  end

  # Writes all entries to CSV files.
  def save_all_to_csv
    save_entries_to_csv(File.join(root.path, @csv_file))
  end

#------------------------------------------------------------------------------
# Public member variables
#------------------------------------------------------------------------------

  attr_accessor :id_range
  attr_accessor :data_files
  attr_accessor :name_files
  attr_accessor :dscr_files
  attr_accessor :csv_file
  attr_accessor :data

#==============================================================================
#                                   PRIVATE
#==============================================================================

  private

  # Determines the data range with given filename.
  #
  # @param _range    [DataRange,Array] Data range
  # @param _filename [String]          Filename
  #
  # @return [DataRange] Data range
  def determine_range(_range, _filename)
    if _range.is_a?(Array)
      _range = _range.find { |_r| _filename.include?(_r.name) }
    end
    _range ||= DataRange.new('', 0x0...0xffffffff)
    _range
  end

  # Determines the PAL-E language for the given filename.
  # @param _filename [String] Filename
  # @return [String] PAL-E language
  def determine_lang(_filename)
    return 'DE' if _filename.include?(SOT_FILE_DE)
    return 'ES' if _filename.include?(SOT_FILE_ES)
    return 'FR' if _filename.include?(SOT_FILE_FR)
    return 'GB' if _filename.include?(SOT_FILE_GB)
    return ''
  end
  
end # class StdEntryData

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end # module ALX
