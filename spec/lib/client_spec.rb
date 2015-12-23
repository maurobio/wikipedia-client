require File.dirname(__FILE__) + '/../spec_helper'
require 'json'

describe Wikipedia::Client, ".find page (mocked)" do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_Dijkstra.json')
    @edsger_content  = JSON::load(File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_content.txt'))['content']
    @client.should_receive(:request).and_return(@edsger_dijkstra)
  end

  it "should execute a request for the page" do
    @client.find('Edsger_Dijkstra')
  end

  it "should return a page object" do
    @client.find('Edsger_Dijkstra').should be_an_instance_of(Wikipedia::Page)
  end

  it "should return a page with the correct content" do
    @page = @client.find('Edsger_Dijkstra')
    @page.content.should == @edsger_content
  end

  it "should return a page with a title of Edsger W. Dijkstra" do
    @page = @client.find('Edsger_Dijkstra')
    @page.title.should == 'Edsger W. Dijkstra'
  end

  it "should return a page with the correct URL" do
    @page = @client.find('Edsger_Dijkstra')
    @page.fullurl.should == 'http://en.wikipedia.org/wiki/Edsger_W._Dijkstra'
  end

  it "should return a page with the correct plain text extract" do
    @page = @client.find('Edsger_Dijkstra')
    @page.text.should start_with 'Edsger Wybe Dijkstra (Dutch pronunciation: '
  end

  it "should return a page with categories" do
    @page = @client.find('Edsger_Dijkstra')
    @page.categories.should == ["Category:1930 births", "Category:2002 deaths", "Category:All pages needing cleanup", "Category:Articles needing cleanup from April 2009", "Category:Articles with close paraphrasing from April 2009", "Category:Computer pioneers", "Category:Dutch computer scientists", "Category:Dutch physicists", "Category:Eindhoven University of Technology faculty", "Category:Fellows of the Association for Computing Machinery"]
  end

  it "should return a page with links" do
    @page = @client.find('Edsger_Dijkstra')
    @page.links.should == ["ACM Turing Award", "ALGOL", "ALGOL 60", "Adi Shamir", "Adriaan van Wijngaarden", "Agile software development", "Alan Kay", "Alan Perlis", "Algorithm", "Allen Newell"]
  end

  it "should return a page with images" do
    @page = @client.find('Edsger_Dijkstra')
    @page.images.should == ["File:Copyright-problem.svg", "File:Dijkstra.ogg", "File:Edsger Wybe Dijkstra.jpg", "File:Speaker Icon.svg", "File:Wikiquote-logo-en.svg"]
  end
end

describe Wikipedia::Client, ".find page with one section (mocked)" do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_Dijkstra_section_0.json')
    @edsger_content = File.read(File.dirname(__FILE__) + '/../fixtures/sanitization_samples/Edsger_W_Dijkstra-sanitized.txt').strip
    @client.should_receive(:request).and_return(@edsger_dijkstra)
  end

  it "should have the correct sanitized intro" do
    @page = @client.find('Edsger_Dijkstra', :rvsection => 0)
    @page.sanitized_content.should == @edsger_content
  end
end

describe Wikipedia::Client, ".find image (mocked)" do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/File_Edsger_Wybe_Dijkstra_jpg.json')
    @client.should_receive(:request).and_return(@edsger_dijkstra)
  end

  it "should execute a request for the image" do
    @client.find_image('File:Edsger Wybe Dijkstra.jpg')
  end

  it "should return a page object" do
    @client.find_image('File:Edsger Wybe Dijkstra.jpg').should be_an_instance_of(Wikipedia::Page)
  end

  it "should return a page with a title of File:Edsger Wybe Dijkstra.jpg" do
    @page = @client.find_image('File:Edsger Wybe Dijkstra.jpg')
    @page.title.should == 'File:Edsger Wybe Dijkstra.jpg'
  end

  it "should return a page with an image url" do
    @page = @client.find_image('File:Edsger Wybe Dijkstra.jpg')
    @page.image_url.should == "http://upload.wikimedia.org/wikipedia/commons/d/d9/Edsger_Wybe_Dijkstra.jpg"
  end
end

describe Wikipedia::Client, ".find page (Edsger_Dijkstra)" do
  before(:each) do
    @client = Wikipedia::Client.new
    @client.follow_redirects = false
  end

  it "should get a redirect when trying Edsger Dijkstra" do
    @page = @client.find('Edsger Dijkstra')
    @page.should be_redirect
  end

  it "should get a final page when follow_redirects is true" do
    @client.follow_redirects = true
    @page = @client.find('Edsger Dijkstra')
    @page.should_not be_redirect
  end

  it "should collect the image urls" do
    @client.follow_redirects = true
    @page = @client.find('Edsger Dijkstra')
    @page.image_urls.should == ["https://upload.wikimedia.org/wikipedia/en/4/4a/Commons-logo.svg", "https://upload.wikimedia.org/wikipedia/commons/5/57/Dijkstra_Animation.gif", "https://upload.wikimedia.org/wikipedia/commons/6/6a/Dining_philosophers.png", "https://upload.wikimedia.org/wikipedia/commons/c/c9/Edsger_Dijkstra_1994.jpg", "https://upload.wikimedia.org/wikipedia/commons/d/d9/Edsger_Wybe_Dijkstra.jpg", "https://upload.wikimedia.org/wikipedia/en/4/48/Folder_Hexagonal_Icon.svg", "https://upload.wikimedia.org/wikipedia/commons/7/7b/Rail-semaphore-signal-Dave-F.jpg", "https://upload.wikimedia.org/wikipedia/commons/2/21/Speaker_Icon.svg", "https://upload.wikimedia.org/wikipedia/commons/f/fa/Wikiquote-logo.svg"]
  end
end

describe Wikipedia::Client, ".find page (Rails) at jp" do
  before(:each) do
    Wikipedia.Configure { domain "ja.wikipedia.org" }
    @client = Wikipedia::Client.new
    @client.follow_redirects = false
  end

  it "should get a redirect when trying Rails" do
    @page = @client.find('Rails')
    @page.should be_redirect
  end

  it "should get a final page when follow_redirects is true" do
    @client.follow_redirects = true
    @page = @client.find('Rails')
    @page.should_not be_redirect
  end
end

describe Wikipedia::Client, ".find random page" do
  before(:each) do
    @client = Wikipedia::Client.new
  end

  it "should get random pages" do
    @page1 = @client.find_random().title
    @page2 = @client.find_random().title
    @page1.should_not == @page2
  end
end

describe Wikipedia::Client, "page.summary (mocked)" do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_Dijkstra.json')
    @edsger_content  = JSON::load(File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_content.txt'))['content']
    @client.should_receive(:request).and_return(@edsger_dijkstra)
  end

  it "should return only the summary" do
    @page = @client.find('Edsger_Dijkstra')
    @page.summary.should == 'Edsger Wybe Dijkstra (Dutch pronunciation: [ˈɛtsxər ˈʋibə ˈdɛikstra] ( ); 11 May 1930 – 6 August 2002) was a Dutch computer scientist. He received the 1972 Turing Award for fundamental contributions to developing programming languages, and was the Schlumberger Centennial Chair of Computer Sciences at The University of Texas at Austin from 1984 until 2000.
Shortly before his death in 2002, he received the ACM PODC Influential Paper Award in distributed computing for his work on self-stabilization of program computation. This annual award was renamed the Dijkstra Prize the following year, in his honor.'
  end

  it "summary returns only the number of characters in the parameter characters" do
    @page = @client.find('Edsger_Dijkstra')
    @page.summary(characters: 7).should == 'Edsger ...'
  end

  it "summary returns only the number of characters in the parameter characters" do
    @page = @client.find('Edsger_Dijkstra')
    @page.summary(sentences: 2).should == "Edsger Wybe Dijkstra (Dutch pronunciation: [ˈɛtsxər ˈʋibə ˈdɛikstra] ( ); 11 May 1930 – 6 August 2002) was a Dutch computer scientist He received the 1972 Turing Award for fundamental contributions to developing programming languages, and was the Schlumberger Centennial Chair of Computer Sciences at The University of Texas at Austin from 1984 until 2000.\nShortly before his death in 2002, he received the ACM PODC Influential Paper Award in distributed computing for his work on self-stabilization of program computation."
  end
end
