#******************************************************************************
# ALX - Skies of Arcadia Legends Examiner
# Copyright (C) 2019 Marcel Renner
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

require_relative('epfile.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================

# Class to read and write DAT files.
class DatFile < EpFile

#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  # Reads a DAT file.
  # @param _filename [String] File name
  def load(_filename)
    _basename   = File.basename(_filename)
    _eb_pattern = File.basename(sys(:eb_file)).sub('*', '\d{3}')
    _ec_pattern = File.basename(sys(:ec_file)).sub('*', '\d{3}')
    if Regexp.new(_eb_pattern) =~ _basename
      _boss = true
    elsif Regexp.new(_ec_pattern) =~ _basename
      _boss = false
    end

    _id = _basename[/\d{3}/]
    if _id
      _id = _id.to_i
      if _boss
        _id += 0x80
      end
    else
      return
    end
    
    LOG.info(sprintf(VOC.open, _filename, VOC.open_read, VOC.open_data))

    CompressedFile.open(root, _filename, 'rb') do |_f|
      LOG.info(sprintf(VOC.read, _id, _f.pos))
      load_enemy(_f, _id, _filename)
    end
    
    LOG.info(sprintf(VOC.close, _filename))
  end

  # Writes a DAT file.
  # @param _filename [String] File name
  def save(_filename)
    _basename   = File.basename(_filename)
    _eb_pattern = File.basename(sys(:eb_file)).sub('*', '\d{3}')
    _ec_pattern = File.basename(sys(:ec_file)).sub('*', '\d{3}')
    if Regexp.new(_eb_pattern) =~ _basename
      _boss = true
    elsif Regexp.new(_ec_pattern) =~ _basename
      _boss = false
    end
    
    _id = _basename[/\d{3}/]
    if _id
      _id = _id.to_i
      if _boss
        _id += 0x80
      end
      
      _enemy = find_enemy(_id, _filename)
      unless _enemy
        return
      end
    else
      return
    end

    unless _enemy.expired
      LOG.info(sprintf(VOC.skip, _filename, VOC.open_data))
      return
    end
    
    LOG.info(sprintf(VOC.open, _filename, VOC.open_write, VOC.open_data))

    CompressedFile.open(root, _filename, 'wb') do |_f|
      LOG.info(sprintf(VOC.write, _id, _f.pos))
      save_enemy(_f, _enemy, _filename)
    end

    LOG.info(sprintf(VOC.close, _filename))
  end

end # class DatFile

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end # module ALX
