class IssuesController < SubdomainController
  before_filter :get_issue, :only => [:show]

  def index
    @subjects = Subject.with_session_bill_count(@session.family)
    # for_sessions(@session.family).order("subjects.name").with_bill_count

    respond_to do |format|
      @issues = ActsAsTaggableOn::Tag.all
      format.js do
        @issues = case params[:sort]
          when "name", "bills"
            ActsAsTaggableOn::Tag.order("name asc")
          when "views"
            ActsAsTaggableOn::Tag.find(Page.most_viewed('Issue').collect(&:og_object_id))
          else
            @issues
        end
      end
      format.html
    end
  end

  def show
    @actions = Action.by_state_and_issue(@state.id, @issue)
    @bills = Bill.by_state_and_issue(@state.id, @issue)
    @sigs = SpecialInterestGroup.by_state_and_issue(@state.id, @issue)

    respond_to do |format|
      format.atom
      format.html
    end
  end

  protected
  def get_issue
    @issue = ActsAsTaggableOn::Tag.find_by_param(params[:id])
    @issue || resource_not_found
  end
end
