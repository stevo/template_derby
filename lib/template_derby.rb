require 'derb/template_handler'
require 'extensions/base_extensions'
require 'extensions/layout_engine'
require 'extensions/protected_rewriter'

ActionController::Base.send :include, Lbuilder::LayoutEngine
ActionController::Base.send :include, Lbuilder::ProtectedRewriter

ActionView::Template.register_default_template_handler :erb, ActionView::TemplateHandlers::DERB
ActionView::Template.register_default_template_handler :derb, ActionView::TemplateHandlers::DERB

ActionView::Base.send :include, DerbHelper
ActionView::Base.send :include, TabsHelper