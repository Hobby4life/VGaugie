
local options = {
	{ "Source", SOURCE, 1 },
  { "GaugeColor", COLOR, WHITE },	
	{ "Min", VALUE, 0, -1024, 1024 },
	{ "Max", VALUE, 100, -1024, 1024 },
  { "LipoGauge", VALUE, 1,0,1 },
}

function create(zone, options,counter)
	local context = { zone=zone, options=options }
  return context
end

local function background(context)

end

-- This function returns green at 100%, red below 30% and graduate in betwwen
local function getPercentColor(cpercent)
    if cpercent < 30 then
      return lcd.RGB(0xff, 0, 0)
    else
      g = math.floor(0xdf * cpercent / 100)
      r = 0xdf - g
      return lcd.RGB(r, g, 0)
    end
end

local function drawGauge(context)
  
	value = getValue(context.options.Source)

	if(value == nil) then
		return
	end

	--Value from source in percentage
	percentageValue = value - context.options.Min;
	percentageValue = (percentageValue / (context.options.Max - context.options.Min)) * 100

	if percentageValue > 100 then
		percentageValue = 100
	elseif percentageValue < 0 then
		percentageValue = 0
	end
  
    --Define gauge positions
  box_spacing = 30
  box_bottom = context.zone.h - box_spacing
  box_left  = context.zone.x
  box_top   = context.zone.y + box_spacing
  box_width = context.zone.w
  box_height = context.zone.y + (box_bottom - box_top)
  
  FLAGS = SHADOWED + CENTER
  
  if context.zone.w < 200 then
    FLAGS = FLAGS
    TEXT_SIZE = 4
  else
    FLAGS = FLAGS + MIDSIZE
    TEXT_SIZE = 6
  end
  
  --Define Source text size and set shadow color manually.
  lcd.setColor(CUSTOM_COLOR, lcd.RGB(0,0,0))
  lcd.drawSource(context.zone.x + (context.zone.w / 2),  context.zone.y  +  1, context.options.Source, FLAGS + CUSTOM_COLOR )
  --Source Text
  lcd.setColor(CUSTOM_COLOR, lcd.RGB(255,248,255))
  lcd.drawSource(context.zone.x + (context.zone.w / 2),  context.zone.y , context.options.Source, FLAGS + CUSTOM_COLOR )
  
  
  
  gauge_height = math.floor((((box_height - 2) / 100) * (100 - percentageValue)) + 2)   
   
  --Background color (gauge is inverted)
  if context.options.LipoGauge > 0 then
    lcd.setColor(CUSTOM_COLOR, getPercentColor(percentageValue))
  else
    lcd.setColor(CUSTOM_COLOR, context.options.GaugeColor)
  end  
  
  --Gauge Color (gauge is inverted)
  lcd.drawFilledRectangle(box_left, box_top, box_width, box_height, CUSTOM_COLOR + SOLID)  

  --Gauge bar
  lcd.setColor(CUSTOM_COLOR, lcd.RGB(200,200,200))
  lcd.drawFilledRectangle( box_left , box_top , box_width , gauge_height , CUSTOM_COLOR + SOLID)
    
  --Gauge Frame outline
  lcd.setColor(CUSTOM_COLOR, lcd.RGB(0,0,0))
  lcd.drawRectangle( box_left , box_top , box_width , box_height , CUSTOM_COLOR )
  lcd.drawRectangle( box_left - 1, box_top + 1, box_width + 2,box_height - 2, CUSTOM_COLOR )

  --Percentage Text
  lcd.setColor(CUSTOM_COLOR, lcd.RGB(255,248,255))
  lcd.drawText(context.zone.x + (context.zone.w / 2) , context.zone.y + (context.zone.h - box_spacing) , math.floor(percentageValue).."%", FLAGS + CUSTOM_COLOR)

end

function update(context, options)
	context.options = options
	context.back = nil
end

function refresh(context)
  
  if context.zone.h < 100 then
    lcd.setColor(CUSTOM_COLOR, lcd.RGB(255,0,0))
    lcd.drawText(context.zone.x + (context.zone.w / 2) , (context.zone.y + (context.zone.h /2)) -10, "Zone to small", SHADOWED + CUSTOM_COLOR + CENTER)
    return
  end
  
  drawGauge(context)
end

return { name="VGaugie", options=options, create=create, update=update, refresh=refresh, background=background }
