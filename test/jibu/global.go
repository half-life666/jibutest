package jibu

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/stoneshi-yunify/jibutest/pkg/utils/random"
	"github.com/elliotchance/pie/pie"
)

const (
	resourcePickRetryLimit    = 10
	jobRetention              = 240
	backupPlanReadyTimeout    = 10 * time.Second
	backupJobFinishedTimeout  = 1 * time.Minute
	restorePlanReadyTimeout   = 5 * time.Minute
	restoreJobFinishedTimeout = 2 * time.Hour
	actionStartJob            = "StartJob"
)

var restoreToSameNamespace = false

var loopCount = 100

var backupWithPV = true

var excludeNamespaces pie.Strings = []string{"kube-system", "kube-public", "kube-node-lease", "qiming-backend", "backup-saas-system"}

var tenant = "test-jjj"

var jibuAPIEndpoint = "http://192.168.0.252:31800"

var ctx = context.Background()

var timestamp = time.Now().Format("20060102150405")

var backupPlanName = strings.ToLower(fmt.Sprintf("backup-%v", timestamp))

var backupJobName = strings.ToLower(fmt.Sprintf("%s-%s", backupPlanName, random.GetRandString(5)))

var restorePlanName = strings.ToLower(fmt.Sprintf("restore-%v", timestamp))

var restoreJobName = strings.ToLower(fmt.Sprintf("%s-%s", restorePlanName, random.GetRandString(5)))
