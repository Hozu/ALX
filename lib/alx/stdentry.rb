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

require_relative('entry.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================

# Base class to handle a standard entry.
class StdEntry < Entry

#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  # Add name data members.
  # @param _size [Integer] Size of name data members
  def add_name_members(_size = 17)
    case region
    when 'E', 'J'
      members << StrVar.new(VOC.name_str[country]  , '', _size)
    when 'P'
      members << IntVar.new(VOC.message_id[country],  0, 'L>' )
      members << IntDmy.new(VOC.name_pos['DE']     ,  0       )
      members << IntDmy.new(VOC.name_size['DE']    ,  0       )
      members << StrDmy.new(VOC.name_str['DE']     , '', '\n' )
      members << IntDmy.new(VOC.name_pos['ES']     ,  0       )
      members << IntDmy.new(VOC.name_size['ES']    ,  0       )
      members << StrDmy.new(VOC.name_str['ES']     , '', '\n' )
      members << IntDmy.new(VOC.name_pos['FR']     ,  0       )
      members << IntDmy.new(VOC.name_size['FR']    ,  0       )
      members << StrDmy.new(VOC.name_str['FR']     , '', '\n' )
      members << IntDmy.new(VOC.name_pos['GB']     ,  0       )
      members << IntDmy.new(VOC.name_size['GB']    ,  0       )
      members << StrDmy.new(VOC.name_str['GB']     , '', '\n' )
    end
  end

  # Add description data members.
  def add_dscr_members
    case region
    when 'E', 'J'
      members << IntDmy.new(VOC.dscr_pos[country] ,  0      )
      members << IntDmy.new(VOC.dscr_size[country],  0      )
      members << StrDmy.new(VOC.dscr_str[country] , ''      )
    when 'P'
      members << IntDmy.new(VOC.dscr_pos['DE']    ,  0      )
      members << IntDmy.new(VOC.dscr_size['DE']   ,  0      )
      members << StrDmy.new(VOC.dscr_str['DE']    , '', '\n')
      members << IntDmy.new(VOC.dscr_pos['ES']    ,  0      )
      members << IntDmy.new(VOC.dscr_size['ES']   ,  0      )
      members << StrDmy.new(VOC.dscr_str['ES']    , '', '\n')
      members << IntDmy.new(VOC.dscr_pos['FR']    ,  0      )
      members << IntDmy.new(VOC.dscr_size['FR']   ,  0      )
      members << StrDmy.new(VOC.dscr_str['FR']    , '', '\n')
      members << IntDmy.new(VOC.dscr_pos['GB']    ,  0      )
      members << IntDmy.new(VOC.dscr_size['GB']   ,  0      )
      members << StrDmy.new(VOC.dscr_str['GB']    , '', '\n')
    end
  end
  
#------------------------------------------------------------------------------
# Public member variables
#------------------------------------------------------------------------------
  
  def msg_id
    _member = find_member(VOC.message_id[country])
    
    if _member
      _member.value
    else
      nil
    end
  end

  def msg_id=(_msg_id)
    _member = find_member(VOC.message_id[country])
    
    if _member
      _member.value = _msg_id
    else
      _msg_id
    end
  end
    
end	# class StdEntry

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end	# module ALX
