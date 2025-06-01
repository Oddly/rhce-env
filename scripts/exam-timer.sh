#!/bin/bash
# RHCE Exam Timer Script

DURATION="${1:-240}"  # Default 4 hours in minutes
MODE="${2:-practice}" # practice or exam

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_time() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))
    printf "%02d:%02d:%02d" $hours $minutes $seconds
}

start_timer() {
    local start_time=$(date +%s)
    local end_time=$((start_time + DURATION * 60))
    
    echo -e "${BLUE}RHCE $MODE Timer Started${NC}"
    echo "Duration: $DURATION minutes"
    echo "Start time: $(date)"
    echo "End time: $(date -d @$end_time 2>/dev/null || date -r $end_time 2>/dev/null || echo "Unknown")"
    echo ""
    
    # Set up signal handlers for clean exit
    trap 'echo -e "\n${YELLOW}Timer interrupted by user${NC}"; exit 0' INT TERM
    
    while true; do
        local current_time=$(date +%s)
        local remaining=$((end_time - current_time))
        
        if [[ $remaining -le 0 ]]; then
            echo -e "\n${RED}🚨 TIME'S UP! 🚨${NC}"
            echo -e "${RED}Session completed at: $(date)${NC}"
            
            # Flash the terminal (if supported)
            for i in {1..5}; do
                echo -e "\a"
                sleep 0.2
            done
            break
        fi
        
        local percent_remaining=$((remaining * 100 / (DURATION * 60)))
        
        # Color coding based on time remaining
        if [[ $percent_remaining -le 10 ]]; then
            color=$RED
        elif [[ $percent_remaining -le 25 ]]; then
            color=$YELLOW
        else
            color=$GREEN
        fi
        
        printf "\r${color}Time remaining: $(print_time $remaining) (${percent_remaining}%%)${NC}"
        
        # Milestone alerts
        if [[ $remaining -eq 1800 ]]; then  # 30 minutes
            echo -e "\n${YELLOW}⚠️  30 minutes remaining!${NC}"
            echo -e "${YELLOW}Time to focus on completing current tasks${NC}"
        elif [[ $remaining -eq 900 ]]; then  # 15 minutes
            echo -e "\n${YELLOW}⚠️  15 minutes remaining!${NC}"
            echo -e "${YELLOW}Start wrapping up your work${NC}"
        elif [[ $remaining -eq 600 ]]; then  # 10 minutes
            echo -e "\n${RED}⚠️  10 minutes remaining!${NC}"
            echo -e "${RED}Begin final checks and documentation${NC}"
        elif [[ $remaining -eq 300 ]]; then  # 5 minutes
            echo -e "\n${RED}🚨 5 minutes remaining!${NC}"
            echo -e "${RED}Save all work and prepare to finish${NC}"
        elif [[ $remaining -eq 60 ]]; then  # 1 minute
            echo -e "\n${RED}🚨 FINAL MINUTE!${NC}"
            echo -e "${RED}Complete any final tasks NOW${NC}"
        fi
        
        sleep 1
    done
    
    echo -e "\n${BLUE}Session statistics:${NC}"
    echo "Total duration: $(print_time $((DURATION * 60)))"
    echo "Session type: $MODE"
    echo "Completed at: $(date)"
}

show_help() {
    echo "RHCE Exam Timer"
    echo "==============="
    echo ""
    echo "Usage: $0 [duration_minutes] [mode]"
    echo ""
    echo "Parameters:"
    echo "  duration_minutes  Timer duration in minutes (default: 240 = 4 hours)"
    echo "  mode             Timer mode: 'practice' or 'exam' (default: practice)"
    echo ""
    echo "Examples:"
    echo "  $0                    # 4-hour practice session"
    echo "  $0 240 exam          # 4-hour exam simulation"
    echo "  $0 30 practice       # 30-minute practice sprint"
    echo "  $0 120 practice      # 2-hour practice session"
    echo ""
    echo "Timer Features:"
    echo "  • Visual countdown with color coding"
    echo "  • Milestone alerts (30min, 15min, 10min, 5min, 1min)"
    echo "  • Percentage remaining display"
    echo "  • Audio alerts when time expires"
    echo "  • Session statistics"
    echo ""
    echo "Keyboard Controls:"
    echo "  Ctrl+C              Stop timer early"
    echo ""
    echo "Exam Mode Notes:"
    echo "  • Simulates real RHCE exam conditions"
    echo "  • Reminds about exam restrictions"
    echo "  • Encourages focused work habits"
}

validate_input() {
    # Validate duration
    if ! [[ "$DURATION" =~ ^[0-9]+$ ]] || [[ $DURATION -lt 1 ]] || [[ $DURATION -gt 1440 ]]; then
        echo -e "${RED}Error: Duration must be a number between 1 and 1440 minutes${NC}"
        exit 1
    fi
    
    # Validate mode
    if [[ "$MODE" != "practice" && "$MODE" != "exam" ]]; then
        echo -e "${RED}Error: Mode must be 'practice' or 'exam'${NC}"
        exit 1
    fi
}

# Handle command line arguments
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Validate inputs
validate_input

# Main execution
case "$MODE" in
    "practice")
        echo -e "${GREEN}Starting RHCE practice session...${NC}"
        echo "Focus areas for practice:"
        echo "• Ansible playbook development"
        echo "• System administration tasks"
        echo "• Troubleshooting and debugging"
        echo ""
        start_timer
        ;;
    "exam")
        echo -e "${BLUE}Starting RHCE exam simulation...${NC}"
        echo ""
        echo -e "${YELLOW}EXAM SIMULATION REMINDERS:${NC}"
        echo "• No internet access allowed during real exam"
        echo "• Only man pages and local documentation permitted"
        echo "• All tasks must be completed within time limit"
        echo "• Test your solutions before considering them complete"
        echo "• Document your approach for complex tasks"
        echo ""
        echo -e "${RED}Good luck with your simulation!${NC}"
        echo ""
        start_timer
        ;;
esac
