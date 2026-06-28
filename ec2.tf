resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ec2-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_instance" "app_server" {
  ami                    = "ami-08f44e8eca9095668"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-USERDATA
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

cat > /var/www/html/index.html << 'HTMLPAGE'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CloudOps Monitoring Dashboard</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; font-family: Arial, sans-serif; }
  body { background: #0f172a; color: #e2e8f0; padding: 2rem; }
  .header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 2rem; }
  .title { font-size: 22px; font-weight: 600; color: #f1f5f9; }
  .subtitle { font-size: 13px; color: #64748b; margin-top: 4px; }
  .badge { background: #052e16; color: #4ade80; border: 1px solid #166534; padding: 4px 12px; border-radius: 20px; font-size: 12px; }
  .grid-4 { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 1.5rem; }
  .grid-2 { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-bottom: 1.5rem; }
  .card { background: #1e293b; border-radius: 12px; border: 1px solid #334155; padding: 1.25rem; }
  .metric-label { font-size: 12px; color: #64748b; margin-bottom: 8px; }
  .metric-value { font-size: 28px; font-weight: 600; }
  .bar-bg { height: 5px; background: #334155; border-radius: 3px; margin-top: 10px; }
  .bar-fill { height: 100%; border-radius: 3px; transition: width 1s; }
  .metric-sub { font-size: 11px; color: #475569; margin-top: 6px; }
  .card-title { font-size: 14px; font-weight: 600; color: #f1f5f9; margin-bottom: 1rem; }
  .status-row { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid #1e293b; font-size: 13px; color: #94a3b8; }
  .status-row:last-child { border-bottom: none; }
  .pill { font-size: 11px; padding: 3px 10px; border-radius: 20px; }
  .ok { background: #052e16; color: #4ade80; }
  .warn { background: #422006; color: #fb923c; }
  .log-row { display: flex; align-items: center; gap: 10px; padding: 8px 0; border-bottom: 1px solid #1e293b; font-size: 13px; }
  .log-row:last-child { border-bottom: none; }
  .dot { width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0; }
  .log-msg { color: #94a3b8; flex: 1; }
  .log-time { color: #475569; font-size: 12px; }
  .bars { display: flex; align-items: flex-end; gap: 8px; height: 100px; margin-top: 0.5rem; }
  .bar-col { flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px; }
  .bar { width: 100%; border-radius: 3px 3px 0 0; }
  .bar-lbl { font-size: 10px; color: #475569; }
</style>
</head>
<body>
<div class="header">
  <div>
    <div class="title">&#9729; CloudOps Monitoring Dashboard</div>
    <div class="subtitle" id="instance-info">Loading instance info...</div>
  </div>
  <span class="badge">&#10003; All systems operational</span>
</div>
<div class="grid-4">
  <div class="card">
    <div class="metric-label">CPU utilization</div>
    <div class="metric-value" id="cpu" style="color:#60a5fa;">42%</div>
    <div class="bar-bg"><div class="bar-fill" id="cpu-bar" style="width:42%;background:#3b82f6;"></div></div>
    <div class="metric-sub">Threshold: 80%</div>
  </div>
  <div class="card">
    <div class="metric-label">Memory utilization</div>
    <div class="metric-value" id="mem" style="color:#4ade80;">61%</div>
    <div class="bar-bg"><div class="bar-fill" id="mem-bar" style="width:61%;background:#22c55e;"></div></div>
    <div class="metric-sub">Threshold: 80%</div>
  </div>
  <div class="card">
    <div class="metric-label">Disk utilization</div>
    <div class="metric-value" id="disk" style="color:#fb923c;">74%</div>
    <div class="bar-bg"><div class="bar-fill" id="disk-bar" style="width:74%;background:#f97316;"></div></div>
    <div class="metric-sub">Threshold: 80%</div>
  </div>
  <div class="card">
    <div class="metric-label">Instance health</div>
    <div class="metric-value" style="color:#4ade80;font-size:20px;margin-top:6px;">&#10003; Healthy</div>
    <div class="bar-bg"><div class="bar-fill" style="width:100%;background:#22c55e;"></div></div>
    <div class="metric-sub">Status check: passed</div>
  </div>
</div>
<div class="grid-2">
  <div class="card">
    <div class="card-title">CPU trend (last 7 days)</div>
    <div class="bars" id="chart"></div>
  </div>
  <div class="card">
    <div class="card-title">Service status</div>
    <div class="status-row"><span>Apache / Nginx</span><span class="pill ok">Running</span></div>
    <div class="status-row"><span>Load balancer</span><span class="pill ok">Active</span></div>
    <div class="status-row"><span>SSM agent</span><span class="pill ok">Connected</span></div>
    <div class="status-row"><span>Database (private)</span><span class="pill ok">Reachable</span></div>
    <div class="status-row"><span>CloudWatch alarms</span><span class="pill ok">No alerts</span></div>
  </div>
</div>
<div class="card">
  <div class="card-title">Recent log activity</div>
  <div class="log-row"><div class="dot" style="background:#22c55e;"></div><span class="log-msg">GET / HTTP/1.1 200 - health check passed</span><span class="log-time">just now</span></div>
  <div class="log-row"><div class="dot" style="background:#22c55e;"></div><span class="log-msg">SSM session started via Session Manager</span><span class="log-time">2m ago</span></div>
  <div class="log-row"><div class="dot" style="background:#f97316;"></div><span class="log-msg">Disk utilization reached 74% - monitor closely</span><span class="log-time">15m ago</span></div>
  <div class="log-row"><div class="dot" style="background:#22c55e;"></div><span class="log-msg">CloudTrail: RunInstances event logged to S3</span><span class="log-time">1h ago</span></div>
  <div class="log-row"><div class="dot" style="background:#22c55e;"></div><span class="log-msg">AWS Backup: daily snapshot completed</span><span class="log-time">3h ago</span></div>
</div>
<script>
  const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
  const vals = [35,52,41,76,38,29,42];
  const chart = document.getElementById('chart');
  chart.innerHTML = days.map((d,i) => {
    const h = Math.round((vals[i]/100)*90);
    const c = vals[i] > 70 ? '#f97316' : '#3b82f6';
    return '<div class="bar-col"><div class="bar" style="height:'+h+'px;background:'+c+';"></div><div class="bar-lbl">'+d+'</div></div>';
  }).join('');
  document.getElementById('instance-info').textContent = 'app-server · ap-south-1a · t3.micro · ' + new Date().toLocaleString();
  setInterval(() => {
    const cpu = Math.round(Math.random()*40+25);
    const mem = Math.round(Math.random()*25+50);
    document.getElementById('cpu').textContent = cpu+'%';
    document.getElementById('mem').textContent = mem+'%';
    document.getElementById('cpu-bar').style.width = cpu+'%';
    document.getElementById('mem-bar').style.width = mem+'%';
  }, 3000);
</script>
</body>
</html>
HTMLPAGE
USERDATA

  tags = {
    Name = "Aryan-app-server"
  }
}

resource "aws_instance" "db_server" {
  ami                    = "ami-08f44e8eca9095668"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-USERDATA
#!/bin/bash
yum update -y
yum install -y mysql-server
systemctl start mysqld
systemctl enable mysqld
USERDATA

  tags = {
    Name = "Aryan-db-server"
  }
}