# Coding: UTF-8

class ServersController < ApplicationController
  def initialize
    @SourcePath = File.expand_path('../', __FILE__)
    @sqlite = SQLite3::Database.open(File.join(@SourcePath, '../../data.db'))
    @sqlite.execute("CREATE TABLE IF NOT EXISTS servers(NAME TEXT, CPU TEXT, MEM_USED TEXT, MEM_FREE TEXT, MEM_SWAP TEXT, Operating_time TEXT, Process_number TEXT, Zombie_process TEXT, High_CPU_Process TEXT, High_MEM_Process TEXT, TEMP TEXT, Update_time TEXT)")
  end
  
  def update
    response.headers['Content-Type'] = 'application/json; charset=utf-8'
    if request.post?
      @response = Hash.new
      unless (params[:NAME] && params[:CPU] && params[:MEM_USED] && params[:MEM_FREE] && params[:MEM_SWAP] && params[:Operating_time] && params[:Process_number] && params[:Zombie_process] && params[:High_CPU_Process] && params[:High_MEM_Process] && params[:TEMP]).nil?
        @sqlite.execute"INSERT INTO servers VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", [params[:NAME], params[:CPU], params[:MEM_USED] , params[:MEM_FREE], params[:MEM_SWAP], params[:Operating_time], params[:Process_number], params[:Zombie_process], params[:High_CPU_Process], params[:High_MEM_Process], params[:TEMP], Time.now.strftime("%Y-%m-%d %H:%M:%S")]
        @response = {
          'code'=> 200,
          'message'=> 'The data has been accepted'
        }.to_json
      else
        @response = {
          'error' => {
                  'code'=> 400,
                  'message' => "Parameter is not enough"
          }
        }.to_json
      end
    else
      redirect_to :action => "show"
      return
    end
  end

  def show
  end
  
  def statues
    response.headers['Content-Type'] = 'application/json; charset=utf-8'
    keys = %w[NAME CPU MEM_USED MEM_FREE MEM_SWAP Operating_time Process_number Zombie_process High_CPU_Process High_MEM_Process TEMP Update_time]
    res = []
    query = "SELECT * FROM servers"
    order = " ORDER BY Update_time "
    period = ""
    where = []
    unless params[:NAME].nil?
      where << "NAME = '#{params[:NAME]}'"
    end
    unless params[:count].nil?
      count = " LIMIT #{params[:count]}"
    else
      count = " LIMIT 100"
    end
    unless params[:period].nil?
      if params[:period][0] == "~"
        params[:period].slice!(0)
        where << "Update_time <= '#{params[:period]}'"
      elsif params[:period][-1] == "~"
        where << "Update_time >= '#{params[:period].chop}'"
      else
        splited = params[:period].split("~")
        where << "Update_time <= '#{splited[1]}'"
        where << "Update_time >= '#{splited[0]}'"
      end
    end
    if where.size > 0
      where.each_with_index do |p, i|
        (query << " WHERE #{p}";next) if i.zero?
        query << " AND #{p}"
      end
    end
    if params[:order].nil?
      order << "DESC"
    else
      order << params[:order]
    end
    query << order << count
    rows = @sqlite.execute(query)
    rows.each do |vals|
      res << Hash[keys.zip vals]
    end
    render :json => res
  end
  
  def stream
    headers["Cache-Control"] ||= "no-cache"
    headers["Transfer-Encoding"] = "chunked"
    keys = %w[NAME CPU MEM_USED MEM_FREE MEM_SWAP Operating_time Process_number Zombie_process High_CPU_Process High_MEM_Process TEMP Update_time]
    self.response_body = Rack::Chunked::Body.new(Enumerator.new do |y|
      before = nil
      res = []
      loop do
        row = @sqlite.execute("SELECT * FROM servers ORDER BY Update_time DESC LIMIT 1")
        unless row == before
          before = row
          y << Hash[keys.zip row[0]].to_json << "\r"
        end
        sleep(5)
      end
    end)
  end
end
