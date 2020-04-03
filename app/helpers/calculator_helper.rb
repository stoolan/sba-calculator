module CalculatorHelper
  def number_input form, var, input_prepend
    desc = Calculator.variables[var][:description]
    content_tag(:tr, class: "form-group") do
      concat(content_tag(:td) { desc })
      concat(content_tag(:td, class: "input-group") do
        concat(content_tag(:div, class: "input-group-prepend") do
          concat(('  <div class="input-group-text">' + input_prepend + '</div>').html_safe)
        end)
        concat(form.number_field(var, class: "form-control", value: (@calc.vars[var])))
      end)
    end.html_safe
  end

  def dollar_input form, var
    number_input(form, var, '$')
  end
  def integer_input form, var
    number_input(form, var, '#')
  end
end
