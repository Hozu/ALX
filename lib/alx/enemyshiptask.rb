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

# Class to handle an enemy ship task.
class EnemyShipTask < Entry

#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  # Constructs an EnemyShipTask.
  # @param _region [String] Region ID
  def initialize(_region)
    super
    @file        = ''
    @enemy_ships = {}
    @magics      = {}

    members << StrDmy.new(VOC.filter             , ''      )
    members << StrDmy.new(VOC.enemy_ship_id      , ''      )
    members << StrDmy.new(VOC.enemy_ship_name    , ''      )
    members << IntVar.new(VOC.unknown[-1]        ,  0, 's>')
    # members << IntVar.new(VOC.task_cond_id       ,  0, 's>')
    # members << StrDmy.new(VOC.task_cond_name     , ''      )
    members << IntVar.new(VOC.task_rating        ,  0, 's>')
    members << IntVar.new(VOC.task_a_type_id     ,  0, 's>')
    members << StrDmy.new(VOC.task_a_type_name   , ''      )
    members << IntVar.new(VOC.task_a_arm_id      ,  0, 's>')
    if region == 'P'
      members << StrDmy.new(VOC.task_a_arm_name  , ''      )
    end
    members << IntVar.new(VOC.task_a_param_id    ,  0, 's>')
    members << StrDmy.new(VOC.task_a_param_name  , ''      )
    members << IntVar.new(VOC.task_a_range       ,  0, 's>')
    members << IntVar.new(VOC.task_b_type_id     ,  0, 's>')
    members << StrDmy.new(VOC.task_b_type_name   , ''      )
    members << IntVar.new(VOC.task_b_arm_id      ,  0, 's>')
    if region == 'P'
      members << StrDmy.new(VOC.task_b_arm_name  , ''      )
    end
    members << IntVar.new(VOC.task_b_param_id    ,  0, 's>')
    members << StrDmy.new(VOC.task_b_param_name  , ''      )
    members << IntVar.new(VOC.task_b_range       ,  0, 's>')
  end

  # Reads one entry from a CSV  file.
  # @param _f [CSV] CSV object
  def read_from_csv(_f)
    super
    @file = find_member(VOC.filter).value
  end
  
  # Writes one entry to a CSV file.
  # @param _f [CSV] CSV object
  def write_to_csv(_f)
    _enemy_id   = SYS.enemy_ship_map[@file]
    _enemy_ship = @enemy_ships[_enemy_id]
    
    find_member(VOC.filter).value        = @file
    find_member(VOC.enemy_ship_id).value = _enemy_id
    
    _name = '???'
    if _enemy_ship
      case region
      when 'E'
        _name = _enemy_ship.find_member(VOC.name_us_str).value
      when 'J'
        _name = _enemy_ship.find_member(VOC.name_jp_str).value
      when 'P'
        _name = _enemy_ship.find_member(VOC.name_gb_str).value
      end
    end
    find_member(VOC.enemy_ship_name).value = _name

    if region == 'P'
      _name = '???'
      if _enemy_ship
        _id = find_member(VOC.task_a_arm_id).value
        if _id > -1
          _name = _enemy_ship.find_member(VOC.arm_name_gb_str[_id]).value
        else
          _name = 'None'
        end
      end
      find_member(VOC.task_a_arm_name).value = _name
      
      _name = '???'
      if _enemy_ship
        _id = find_member(VOC.task_b_arm_id).value
        if _id > -1
          _name = _enemy_ship.find_member(VOC.arm_name_gb_str[_id]).value
        else
          _name = 'None'
        end
      end
      find_member(VOC.task_b_arm_name).value = _name
    end

    _id = find_member(VOC.task_a_type_id).value
    find_member(VOC.task_a_type_name).value = VOC.task_types[_id]
    
    _id = find_member(VOC.task_b_type_id).value
    find_member(VOC.task_b_type_name).value = VOC.task_types[_id]

    _type_id    = find_member(VOC.task_a_type_id ).value
    _param_id   = find_member(VOC.task_a_param_id).value
    _type_name  = VOC.task_types[_type_id]
    _param_name = _param_id != -1 ? '???' : 'None'
    case _type_id
    when 0
      _param_name = 'None'
    when 1
      _entry = @magics[_param_id]
      if _entry
        case region
        when 'E'
          _param_name = _entry.find_member(VOC.name_us_str).value
        when 'J'
          _param_name = _entry.find_member(VOC.name_jp_str).value
        when 'P'
          _param_name = _entry.find_member(VOC.name_gb_str).value
        end
      end
    when 2
      _param_name = VOC.focus_tasks[_param_id]
    when 3
      _param_name = VOC.guard_tasks[_param_id]
    when 4
      _param_name = VOC.nothing_tasks[_param_id]
    end
    find_member(VOC.task_a_type_name ).value = _type_name
    find_member(VOC.task_a_param_name).value = _param_name
    
    _type_id    = find_member(VOC.task_b_type_id ).value
    _param_id   = find_member(VOC.task_b_param_id).value
    _type_name  = VOC.task_types[_type_id]
    _param_name = _param_id != -1 ? '???' : 'None'
    case _type_id
    when -1
      _param_name = 'None'
    when 0
      _param_name = 'None'
    when 1
      _entry = @magics[_param_id]
      if _entry
        case region
        when 'E'
          _param_name = _entry.find_member(VOC.name_us_str).value
        when 'J'
          _param_name = _entry.find_member(VOC.name_jp_str).value
        when 'P'
          _param_name = _entry.find_member(VOC.name_gb_str).value
        end
      end
    when 2
      _param_name = VOC.focus_tasks[_param_id]
    when 3
      _param_name = VOC.guard_tasks[_param_id]
    when 4
      _param_name = VOC.nothing_tasks[_param_id]
    end
    find_member(VOC.task_b_type_name ).value = _type_name
    find_member(VOC.task_b_param_name).value = _param_name
    
    super
  end

#------------------------------------------------------------------------------
# Public member variables
#------------------------------------------------------------------------------

  attr_accessor :file
  attr_accessor :enemy_ships
  attr_accessor :magics

end	# class EnemyShipTask

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end	# module ALX
