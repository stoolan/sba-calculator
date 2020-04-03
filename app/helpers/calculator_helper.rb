module CalculatorHelper
  def number_input form, var, input_prepend
    desc = Calculator.variables[var][:description]
    ['1', '2', '3', '4', '5'].each do |footnote|
      if desc.include? ("(#{footnote})")
        desc = desc.gsub("(#{footnote})", link_to_footnote(footnote))
      end
    end
    content_tag(:tr, class: "form-group") do
      concat(content_tag(:td) { desc.html_safe })
      concat(content_tag(:td, class: "input-group") do
        concat(content_tag(:div, class: "input-group-prepend") do
          concat(('  <div class="input-group-text">' + input_prepend + '</div>').html_safe)
        end)
        concat(form.number_field(var, class: "form-control", value: (@calc.vars[var].to_i), onchange: 'this.form.submit();'))
      end)
    end.html_safe
  end

  def dollar_input form, var
    number_input(form, var, '$')
  end
  def integer_input form, var
    number_input(form, var, '#')
  end
  def link_to_footnote(footnote_number)
    content_tag(:sup) do
      concat(link_to(footnote_number, "##{footnote_number}"))
    end
  end
end
